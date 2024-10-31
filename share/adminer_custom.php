<?php
/**
 * !!! DON'T EDIT adminer/index.php, EDIT adminer_custom.php
 * https://docs.adminerevo.org/#to-use-a-plugin
 * Installation: adminer_update_activate
 */
function adminer_object() {
    // required to run any plugin
    include_once "../plugins/plugin.php";

    // // autoloader
    // foreach (glob("../plugins/*.php") as $filename) {
    //     include_once "./$filename";
    // }

    include_once "../plugins/json-column.php";
    include_once "../plugins/pretty-json-column.php";
    include_once "../plugins/login-password-less.php";
    include_once "../plugins/login-ssl.php";

    $adminer_hash = getenv("ADMINER_HASH"); // env.sh

    $plugins = array(
        // specify enabled plugins here

        new AdminerJsonColumn(),
        new AdminerLoginPasswordLess($adminer_hash),
        new AdminerLoginSsl([])
    );

    // It is possible to combine customization and plugins:
    class AdminerCustomization extends AdminerPlugin {
      function permanentLogin($create = false) {
        return $adminer_hash;
      }
    }

    $adminer = new AdminerCustomization($plugins);

    // These need the $adminer instance
    $adminer->plugins[] = new AdminerPrettyJsonColumn($adminer);

    return $adminer;

    // return new AdminerPlugin($plugins);
}

// include original Adminer or Adminer Editor
require_once "./index.orig.php";
