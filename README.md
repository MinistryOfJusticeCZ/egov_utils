[![pipeline status](https://git.servis.justice.cz/libraries/egov_utils-rails/badges/master/pipeline.svg)](https://git.servis.justice.cz/libraries/egov_utils-rails/commits/master)
# EgovUtils
This gem is set of utilities commonly used in Czech egoverment for rails application.

Main features:
* User roles/permissions
* Ldap integration
* Addresses/people storing and validation trough Egsb - ( uses egsb_gate gem )
* Usefull additions for bootstrap ( will be separeted in feature )
* Data visualization and retrievement api ( uses azahara_schema gem )

To be done:
* NIA integration
* ISDS SSO integration

## Usage

Detailed developers documentation can be found at [Documentation](https://git.servis.justice.cz/libraries/egov_utils-rails/wikis/home).

Framework uses configuration in file config/config.yml

### LDAP
LDAP parameters has to be configured in framework config file under the key `ldap`.
You can configure more than one ldap source. Framework will try all of them. But groups and users are resolved just by the one ldap controller where user resides.
Following example is for Active Directory ldap using userPrincipalName as username (prefered - in case of multidomain ldap controller it should be mandatory)
```yaml
ldap:
  main:
    label: 'Lab'
    # host: dc01.servis.resort.cz
    domain: servis.resort.cz
    resolve_host: true
    port: 389
    uid: 'userPrincipalName'
    method: 'tls'
    kerberos: true
    bind_dn: 'CN=Uzivatel LDAP aplikace ABC,OU=Servisni,DC=servis,DC=resort,DC=cz'
    password: 'heslo uzivatele LDAP aplikace'
    active_directory: true #enables specific Active Directory functions
    base: 'OU=Appname,DC=servis,DC=resort,DC=cz'
    onthefly_register: members
    attributes:
      username: ['userPrincipalName']
      email: ['mail', 'email']
      name: 'cn'
      first_name: 'givenName'
      last_name: 'sn'
```
#### Authentication to reading ldap and security
Authentication options are made trough `bind_dn` and `password` options.
`bind_dn` id DN of user with read permissions for all ldap tree ( or the subtree wich relates to this application ) and `password` is a password for this user.

#### Defining host
Host can be defined in option `host`, but in bigger ldap installation you would prefer to use selection of the host on DNS for load balancing purposes.

It can be done by defining option `domain` and `resolve_host: true`.
Framework will let DNS resolve the servis record `_ldap._tcp.<domain>` and select the first record.
It relies on resolution of this record to be sorted from less busy controller to most busy.
It is prefered method for bigger ldaps with load balancing demands.

Option `port` has to be defined if you are using `host` option.
For `resolve_host` option, you can leave out the host option and framework will use the port returned by DNS server.
But you can wish to define it anyway, if you have global catalog running on another port.

Option `method` is for defining a security protocol, wich shoul be used for comunication with the ldap controller.
* plain
* ssl
* tls
You should always use encrypted connection, so please consider plain method to be just for testing purposes to connect to the test ldap controller.

#### Base and attributes
First you have to specify, where to look for records of users and groups related to the application.
`base` could be just domain like `DC=servis,DC=resort,DC=cz`, but you should consider to narrowing the scope for performance purposes, so if your users and groups are in specific Organization Unit, you should define DN of the OU as a base.

Attributes defines mapping for attributes in LDAP to attributes in the application database.
If you are using activedirectory, you probably will want to keep the attributes same as in the example.
But if you want to change them, you can do it. They are pretty self expanatory.

#### Onthefly registration
This parameter defines if administartor has to create the accounts (add users from AD) manually, or it can be created (added) with first login.

Parameter `onthefly_register` set to `true` basically saying, that any user in the scope defined by `base` is allowed to login to the application.
It can be usefull for easy applications, where you create organization unit for them and special account for every user of the application.
Or on the other hand if the application is for whole resort and you specify the roles and permissions in the application.


More interesting is an option `members`.
With this option, framework will look in all groups added as groups in application and if the user is member of at least one of them, application will create the account.
Other users can be added manually by administrator. Membership in groups is looked for recursively.

#### Groups
You can add LDAP groups to the application groups and define roles and permissions to the groups.
Group membership is solved on the fly for the user, so it does´t depens on the order of making user a memmber of group and adding the group to the application.
Group membership is looked for recursively, so you can add one big group, define permissions for that group, add other groups as members and end users to this groups.
This ordering can be useful for more sub organizations, where every organization is managing its users permissions and then it is connected to the global AD catalog, where the application is queriing.

#### Kerberos
To be documented.

## Installation
Add this lines to your application's Gemfile:

```ruby
gem 'egov_utils'

source 'https://rails-assets.org' do
  gem 'rails-assets-tether', '>= 1.3.3'
end
```
Because it is not possible to add a tether as a dependency (as long as it is from other source), you need to add it to your own Gemfile.

And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install egov_utils
```

## Contributing
Contribution directions go here.

## License
The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
