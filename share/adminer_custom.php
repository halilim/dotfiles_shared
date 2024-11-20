<?php

require_once "./adminer_password.php";

/**
 * !!! DON'T EDIT adminer/index.php, EDIT adminer_custom.php
 * https://docs.adminerevo.org/#to-use-a-plugin
 * Installation: adminer_update_activate
 */
function adminer_object() {
    include_once "../plugins/plugin.php";
    include_once "../plugins/json-column.php";
    include_once "../plugins/pretty-json-column.php";
    include_once "../plugins/login-password-less.php";
    include_once "../plugins/login-ssl.php";

    $plugins = array(
        new AdminerJsonColumn(),
        new AdminerLoginPasswordLess(password_hash(ADMINER_PASSWORD, PASSWORD_DEFAULT)),
        new AdminerLoginSsl([])
    );

    // It is possible to combine customization and plugins:
    class AdminerCustomization extends AdminerPlugin {
      function permanentLogin($create = false) {
        return ADMINER_PASSWORD;
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
