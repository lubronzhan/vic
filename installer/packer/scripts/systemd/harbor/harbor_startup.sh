# Copyright 2017 VMware, Inc. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# assume harbor put under this doc
harbor_dir=/etc/vmware/harbor

# Modify harbor.cfg
#Configure attr in harbor.cfg
function configureHarborCfg {
	cfg_key=$1
	cfg_value=$2

	cfg_file="$harbor_dir"/harbor.cfg

	if [ -n "$cfg_key" ]
	then
		cfg_value=$(echo "$cfg_value" | sed -r -e 's%[\/&%]%\\&%g')
		sed -i -r "s%#?$cfg_key\s*=\s*.*%$cfg_key = $cfg_value%" $cfg_file
	fi
}


ip_address=$(ovfenv --key network.ip0)
if [[  -z  $ip_address  ]]
then 
    ip_address=$(ifconfig eth0 | grep 'inet addr' | cut -d ':' -f 2 | cut -d ' ' -f 1)
fi
configureHarborCfg "hostname" "$ip_address"

email_server=$(ovfenv --key appliance.email_server)
if [[  -n  $email_server  ]]
then 
    configureHarborCfg "email_server" "$email_server"
fi

email_server_port=$(ovfenv --key appliance.email_server_port)
if [[  -n  $email_server_port  ]]
then 
    configureHarborCfg "email_server_port" "$email_server_port"
fi

email_username=$(ovfenv --key appliance.email_username)
if [[  -n  $email_username  ]]
then 
    configureHarborCfg "email_username" "$email_username"
fi

email_password=$(ovfenv --key appliance.email_password)
if [[  -n  $email_password  ]]
then 
    configureHarborCfg "email_password" "$email_password"
fi

email_from=$(ovfenv --key appliance.email_from)
if [[  -n  $email_from  ]]
then 
    configureHarborCfg "email_from" "$email_from"
fi

email_ssl=$(ovfenv --key appliance.email_ssl)
if [[  -n  $email_ssl  ]]
then 
    configureHarborCfg "email_ssl" "$email_ssl"
fi

admin_password=$(ovfenv --key harbor.admin_password)
if [[  -n  $admin_password  ]]
then 
    configureHarborCfg "harbor_admin_password" "$admin_password"
fi

db_password=$(ovfenv --key harbor.db_password)
if [[  -n  $db_password  ]]
then 
    configureHarborCfg "db_password" "$db_password"
fi

ssl_cert=$(ovfenv --key harbor.ssl_cert)
if [[  -n  $ssl_cert  ]]
then 
    configureHarborCfg "ssl_cert" "$ssl_cert"
fi

ssl_cert_key=$(ovfenv --key harbor.ssl_cert_key)
if [[  -n  $ssl_cert_key  ]]
then 
    configureHarborCfg "ssl_cert_key" "$ssl_cert_key"
fi


# remove docker-compose starting part, save it to systemd ExecStart
sed  '/.*starting Harbor.*/,$d' "$harbor_dir"/install.sh

# install harbor
/usr/bin/python "$harbor_dir"/prepare

/bin/bash "$harbor_dir"/install.sh

