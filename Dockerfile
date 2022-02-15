FROM bitnami/openldap:latest
FROM ltbproject/self-service-password:latest
FROM ldapaccountmanager/lam:latest
# Add ldap ANS config
COPY config.cfg /etc/ldap-account-manager/config.cfg
COPY lam.conf /var/lib/ldap-account-manager/config/lam.conf
