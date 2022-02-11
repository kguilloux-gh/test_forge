project = "forge_ans/ldap"

labels = { "domaine" = "ldap" }

runner {
    enabled = true
    data_source "git" {
        url = "https://github.com/kguilloux-gh/test_forge"
        ref = "main"
    }
}
