1. Generate GnuPG a key pair or copy it.
   - Generate a key pair
     ```console
     $ gpg --full-generate-key
     ```

   - Copy a key pair to remote
     ```console
     $ gpg --pinentry-mode loopback --export-secret-keys --passphrase <passphrase> | ssh remote gpg --pinentry-mode loopback --passphrase <passphrase> --import
     ```

2. Encrypt `.netrc` file or copy encrypted file.
   - Encrypt
     ```console
     $ gpg --encrypt ~/.netrc
     ```

   - Copy
     ```console
     $ scp ~/.netrc.gpg remote:~/
     ```
