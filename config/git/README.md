1. Generate a key pair or copy it.
   - Generate a key pair
     ```console
     $ gpg --full-generate-key
     ```

   - Copy a key pair to remote
     ```console
     $ gpg --pinentry-mode loopback --export-secret-keys --passphrase <passphrase> | ssh remote gpg --pinentry-mode loopback --passphrase <passphrase> --import
     ```

     Trust a copied key pair
     ```console
     $ gpg --edit-key user@useremail.com

     gpg> trust

     Please decide how far you trust this user to correctly verify other users' keys
     (by looking at passports, checking fingerprints from different sources, etc.)

       1 = I don't know or won't say
       2 = I do NOT trust
       3 = I trust marginally
       4 = I trust fully
       5 = I trust ultimately
       m = back to the main menu

     Your decision? 5
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
