<!-- markdownlint-disable no-inline-html first-line-heading -->

A compatible server is required, e.g. Nextcloud, Koofr, etc.
Configuration examples are provided below.

### Nextcloud Configuration

1. Create a dedicated app password in your Nextcloud:

   - Go to Profile → Settings → Security → bottom of the page
   - Enter an app name (e.g., "mhabit" or "test") and confirm your password
     ![Create new app][nextcloud-test-app]
   - Save the generated password
     ![Retrieve app credentials][nextcloud-test-app-credentials]

2. Configure mhabit with your Nextcloud server:

   - Go to Settings → Sync Options → Sync Server → Current: WebDAV
   - Enter your server URL (format: `https://example.com/remote.php/dav/files/[nextcloud user]`)
     ![Server configuration][nextcloud-test-app-server-config]

3. Perform initial sync:

   - Now return back to Settings
   - Click the refresh button next to `Sync Now`
   - Successful connection will display sync status
     ![First synchronization][nextcloud-test-app-first-sync]

4. Enjoy automatic sync:
   - Additional syncs will occur without other modals
   - Verify sync status by checking the last sync timestamp
     ![Success synchronizations][nextcloud-test-app-sync-success]

### Koofr Configuration

Follow the ["How do I connect a service to Koofr through WebDAV?"][koofr-webdav]
guide to create an application password and complete the connection settings in the app.

> A1: Don’t use the root directory directly. Instead, create your own folder inside Koofr,
> e.g. `https://app.koofr.net/dav/Koofr/your-folder-name/`
>
> A2: If you see 429 error, please refer to [Error 429][koofr-err429].

<!-- refs -->

[nextcloud-test-app]: images/webdav-sync-nextcloud/nextcloud-test-app.png
[nextcloud-test-app-credentials]: images/webdav-sync-nextcloud/nextcloud-test-app-credentials.png
[nextcloud-test-app-server-config]: images/webdav-sync-nextcloud/nextcloud-test-app-server-config.png
[nextcloud-test-app-first-sync]: images/webdav-sync-nextcloud/nextcloud-test-app-first-sync.png
[nextcloud-test-app-sync-success]: images/webdav-sync-nextcloud/nextcloud-test-app-sync-success.png
[koofr-webdav]: https://app.koofr.net/help/webdav#a-idhow-do-i-connect-a-service-to-koofr-through-webdava-how-do-i-connect-a-service-to-koofr-through-webdav
[koofr-err429]: https://app.koofr.net/help/webdav#a-iderror-429a-error-429

---

1. [2025-07-29] Migrated from: [`FriesI23/mhabit/README.md`][_migrate]

[_migrate]: https://github.com/FriesI23/mhabit/blob/09f6cabd6f7b2fa3aca1c087d48e9a6069c28033/README.md
