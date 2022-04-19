#!/usr/bin/env python
import argparse
import itertools
import os
import shlex
import subprocess
import sys


class Credential(object):
    def __init__(self, file="~/.netrc.gpg"):
        self.hosts = dict()

        self.file = os.path.expanduser(file)
        assert os.path.exists(self.file), f"file {file} not found."

        proc = subprocess.run(
            ("gpg --pinentry-mode loopback --decrypt " f"{self.file}").split(),
            stdout=subprocess.PIPE,
        )

        if proc.returncode != 0:
            raise ValueError(
                f"ReturnCode({proc.returncode}) from \"{' '.join(proc.args)}\"\n"
            )

        netrc = proc.stdout.decode()
        self._parse(netrc)

    def _parse(self, netrc):

        lexer = shlex.shlex(netrc)
        lexer.wordchars += r"""!"#$%&'()*+,-./:;<=>?@[\]^_`{|}~"""
        lexer.commenters = lexer.commenters.replace("#", "")

        while 1:
            # Look for a machine, default, or macdef top-level keyword
            saved_lineno = lexer.lineno
            toplevel = tt = lexer.get_token()
            if not tt:
                break
            elif tt[0] == "#":
                if lexer.lineno == saved_lineno and len(tt) == 1:
                    lexer.instream.readline()
                continue
            elif tt == "machine":
                entryname = lexer.get_token()
            elif tt == "default":
                entryname = "default"
            else:
                raise ValueError("bad toplevel token %r" % tt, self.file, lexer.lineno)

            login = ""
            protocol = account = password = None
            if entryname not in self.hosts:
                self.hosts[entryname] = []
            while 1:
                tt = lexer.get_token()
                if tt.startswith("#") or tt in {"", "machine", "default", "macdef"}:
                    if password:
                        self.hosts[entryname].append(
                            (login, account, protocol, password)
                        )
                        lexer.push_token(tt)
                        break
                    else:
                        raise ValueError(
                            "malformed %s entry %s terminated by %s"
                            % (toplevel, entryname, repr(tt)),
                            self.file,
                            lexer.lineno,
                        )
                elif tt == "login" or tt == "user":
                    login = lexer.get_token()
                elif tt == "account":
                    account = lexer.get_token()
                elif tt == "password":
                    password = lexer.get_token()
                elif tt == "protocol":
                    protocol = lexer.get_token()

    def get(self, query_host=None, query_username=None, query_protocol=None):

        res = []
        # logic to get username/password from auth file
        if query_host and query_host in self.hosts:
            for credential in self.hosts[query_host]:
                username, account, protocol, password = credential
                if (query_username is None or query_username == username) and (
                    query_protocol is None
                    or protocol is None
                    or query_protocol == protocol
                ):
                    res.append(dict(username=username, password=password))
        else:
            for credential in itertools.chain.from_iterable(self.hosts.values()):
                username, account, protocol, password = credential
                if (query_username is None or query_username == username) and (
                    query_protocol is None
                    or protocol is None
                    or query_protocol == protocol
                ):
                    res.append(dict(username=username, password=password))
        return res

    def store(self):
        # logic to store username/password to auth file
        # its better to encrypt password if its in plain text
        pass

    def erase(self):
        # logic to delete auth file
        pass


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--netrc", type=str, default=os.path.expanduser("~/.netrc.gpg"))
    parser.add_argument(
        "operation",
        action="store",
        type=str,
        help="Git action to be performed (get|store|erase)",
    )
    # parser all arguments
    args = parser.parse_args()

    if not os.path.exists(args.netrc):
        return

    # get credentials
    cre = Credential(args.netrc)

    if args.operation == "get":

        protocol = host = username = None
        if not sys.stdin.isatty():
            for line in sys.stdin:
                k, v = line.split("=")
                if k == "protocol":
                    protocol = v.strip()
                elif k == "host":
                    host = v.strip()
                elif k == "username":
                    username = v.strip()

        results = cre.get(host, username, protocol)
        if results:
            for result in results:
                for k, v in result.items():
                    print(f"{k}={v}")
                print()
    else:
        print("Invalid git operation")


if __name__ == "__main__":
    main()
