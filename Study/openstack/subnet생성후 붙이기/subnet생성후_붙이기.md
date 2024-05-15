[root@con-250-2 (kimbh0132-rc): ~]# openstack network create pentachord-192
[root@con-250-2 (kimbh0132-rc): ~]# openstack subnet create --network pentachord-192 --subnet-range 192.168.0.0/16 --dhcp pentachord-192
[root@con-250-2 (kimbh0132-rc): ~]# openstack network show 650474fa-e660-4098-9918-59dc29545ce8
+---------------------------+--------------------------------------+
| Field                     | Value                                |
+---------------------------+--------------------------------------+
| admin_state_up            | UP                                   |
| availability_zone_hints   |                                      |
| availability_zones        | nova                                 |
| created_at                | 2024-01-25T00:52:08Z                 |
| description               |                                      |
| dns_domain                | None                                 |
| id                        | 650474fa-e660-4098-9918-59dc29545ce8 |
| ipv4_address_scope        | None                                 |
| ipv6_address_scope        | None                                 |
| is_default                | None                                 |
| is_vlan_transparent       | None                                 |
| mtu                       | 1450                                 |
| name                      | pentachord-2                         |
| port_security_enabled     | True                                 |
| project_id                | 65ce28faf04649b4ae8e1c3f7a00198d     |
| provider:network_type     | vxlan                                |
| provider:physical_network | None                                 |
| provider:segmentation_id  | 18                                   |
| qos_policy_id             | None                                 |
| revision_number           | 4                                    |
| router:external           | Internal                             |
| segments                  | None                                 |
| shared                    | False                                |
| status                    | ACTIVE                               |
| subnets                   | 37d05d3f-11de-414e-8fca-b41204bde9e6 |
| tags                      |                                      |
| updated_at                | 2024-01-25T07:01:00Z                 |
+---------------------------+--------------------------------------+

[root@con-250-2 (kimbh0132-rc): ~]# openstack port list | grep 37d05d3f-11de-414e-8fca-b41204bde9e6
[root@con-250-2 (kimbh0132-rc): ~]# openstack router remove port aabafb22-474b-4e54-a44c-b83020c3b156 47f04538-adba-4a9d-b405-a362dc13854d
# openstack router remove port 'router-id' 'port-id'
[root@con-250-2 (kimbh0132-rc): ~]# openstack router show aabafb22-474b-4e54-a44c-b83020c3b156
+-------------------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| Field                   | Value                                                                                                                                                                                                                                                                       |
+-------------------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| admin_state_up          | UP                                                                                                                                                                                                                                                                          |
| availability_zone_hints |                                                                                                                                                                                                                                                                             |
| availability_zones      | nova                                                                                                                                                                                                                                                                        |
| created_at              | 2024-01-25T00:52:36Z                                                                                                                                                                                                                                                        |
| description             |                                                                                                                                                                                                                                                                             |
| distributed             | False                                                                                                                                                                                                                                                                       |
| external_gateway_info   | {"network_id": "09ee00f6-bfdd-4071-9258-8ff04e4ad038", "external_fixed_ips": [{"subnet_id": "1eac536c-2b4a-4e65-abf6-6ccb725affa8", "ip_address": "115.68.250.91"}], "enable_snat": true}                                                                                   |
| flavor_id               | None                                                                                                                                                                                                                                                                        |
| ha                      | False                                                                                                                                                                                                                                                                       |
| id                      | aabafb22-474b-4e54-a44c-b83020c3b156                                                                                                                                                                                                                                        |
| interfaces_info         | [{"port_id": "c0968d20-1d18-42fd-82f5-484cec774d45", "ip_address": "10.0.0.1", "subnet_id": "def598ca-9b1c-4b87-8114-3af4ad032755"}, {"port_id": "e348f861-90d5-46a0-b60d-2b8070e61e6f", "ip_address": "192.168.0.1", "subnet_id": "37d05d3f-11de-414e-8fca-b41204bde9e6"}] |
| name                    | pentachord-router                                                                                                                                                                                                                                                           |
| project_id              | 65ce28faf04649b4ae8e1c3f7a00198d                                                                                                                                                                                                                                            |
| revision_number         | 9                                                                                                                                                                                                                                                                           |
| routes                  |                                                                                                                                                                                                                                                                             |
| status                  | ACTIVE                                                                                                                                                                                                                                                                      |
| tags                    |                                                                                                                                                                                                                                                                             |
| updated_at              | 2024-01-25T07:14:44Z                                                                                                                                                                                                                                                        |
+-------------------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
[root@con-250-2 (kimbh0132-rc): ~]# openstack network delete 650474fa-e660-4098-9918-59dc29545ce8

openstack port delete 650474fa-e660-4098-9918-59dc29545ce8 

openstack router list
openstack server list
openstack port
openstack port delete
openstack port delete -h
openstack port list | grep penta
openstack port list
openstack port list | grep 172.16.0.10[root@con-250-2 (kimbh0132-rc): ~]# openstack network create pentachord-192
[root@con-250-2 (kimbh0132-rc): ~]# openstack subnet create --network pentachord-192 --subnet-range 192.168.0.0/16 --dhcp pentachord-192
[root@con-250-2 (kimbh0132-rc): ~]# openstack network show 650474fa-e660-4098-9918-59dc29545ce8
+---------------------------+--------------------------------------+
| Field                     | Value                                |
+---------------------------+--------------------------------------+
| admin_state_up            | UP                                   |
| availability_zone_hints   |                                      |
| availability_zones        | nova                                 |
| created_at                | 2024-01-25T00:52:08Z                 |
| description               |                                      |
| dns_domain                | None                                 |
| id                        | 650474fa-e660-4098-9918-59dc29545ce8 |
| ipv4_address_scope        | None                                 |
| ipv6_address_scope        | None                                 |
| is_default                | None                                 |
| is_vlan_transparent       | None                                 |
| mtu                       | 1450                                 |
| name                      | pentachord-2                         |
| port_security_enabled     | True                                 |
| project_id                | 65ce28faf04649b4ae8e1c3f7a00198d     |
| provider:network_type     | vxlan                                |
| provider:physical_network | None                                 |
| provider:segmentation_id  | 18                                   |
| qos_policy_id             | None                                 |
| revision_number           | 4                                    |
| router:external           | Internal                             |
| segments                  | None                                 |
| shared                    | False                                |
| status                    | ACTIVE                               |
| subnets                   | 37d05d3f-11de-414e-8fca-b41204bde9e6 |
| tags                      |                                      |
| updated_at                | 2024-01-25T07:01:00Z                 |
+---------------------------+--------------------------------------+

[root@con-250-2 (kimbh0132-rc): ~]# openstack port list | grep 37d05d3f-11de-414e-8fca-b41204bde9e6

[root@con-250-2 (kimbh0132-rc): ~]# openstack router remove port aabafb22-474b-4e54-a44c-b83020c3b156 47f04538-adba-4a9d-b405-a362dc13854d
# openstack router remove port 'router-id' 'port-id'
[root@con-250-2 (kimbh0132-rc): ~]# openstack router show aabafb22-474b-4e54-a44c-b83020c3b156
+-------------------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| Field                   | Value                                                                                                                                                                                                                                                                       |
+-------------------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| admin_state_up          | UP                                                                                                                                                                                                                                                                          |
| availability_zone_hints |                                                                                                                                                                                                                                                                             |
| availability_zones      | nova                                                                                                                                                                                                                                                                        |
| created_at              | 2024-01-25T00:52:36Z                                                                                                                                                                                                                                                        |
| description             |                                                                                                                                                                                                                                                                             |
| distributed             | False                                                                                                                                                                                                                                                                       |
| external_gateway_info   | {"network_id": "09ee00f6-bfdd-4071-9258-8ff04e4ad038", "external_fixed_ips": [{"subnet_id": "1eac536c-2b4a-4e65-abf6-6ccb725affa8", "ip_address": "115.68.250.91"}], "enable_snat": true}                                                                                   |
| flavor_id               | None                                                                                                                                                                                                                                                                        |
| ha                      | False                                                                                                                                                                                                                                                                       |
| id                      | aabafb22-474b-4e54-a44c-b83020c3b156                                                                                                                                                                                                                                        |
| interfaces_info         | [{"port_id": "c0968d20-1d18-42fd-82f5-484cec774d45", "ip_address": "10.0.0.1", "subnet_id": "def598ca-9b1c-4b87-8114-3af4ad032755"}, {"port_id": "e348f861-90d5-46a0-b60d-2b8070e61e6f", "ip_address": "192.168.0.1", "subnet_id": "37d05d3f-11de-414e-8fca-b41204bde9e6"}] |
| name                    | pentachord-router                                                                                                                                                                                                                                                           |
| project_id              | 65ce28faf04649b4ae8e1c3f7a00198d                                                                                                                                                                                                                                            |
| revision_number         | 9                                                                                                                                                                                                                                                                           |
| routes                  |                                                                                                                                                                                                                                                                             |
| status                  | ACTIVE                                                                                                                                                                                                                                                                      |
| tags                    |                                                                                                                                                                                                                                                                             |
| updated_at              | 2024-01-25T07:14:44Z                                                                                                                                                                                                                                                        |
+-------------------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
[root@con-250-2 (kimbh0132-rc): ~]# openstack network delete 650474fa-e660-4098-9918-59dc29545ce8

openstack port delete 650474fa-e660-4098-9918-59dc29545ce8 
openstack router list
openstack server list
openstack port
openstack port delete
openstack port delete -h
openstack port list | grep penta
openstack port list
openstack port list | grep 172.16.0.10
openstack port -h
openstack port unset -h
openstack port delete
openstack port delete -h
openstack port delete --help
openstack port delete --fixed-ip subnet=255.255.0.0,ip-address=172.16.0.10
openstack port delete --fixed-ip subnet=255.255.0.0, ip-address=172.16.0.10
openstack port list | grep 172.16.0.10
openstack port unset 8f4451e4-02e1-43e7-a221-51df0d4577e6
nova show a812e8cf-d814-410c-9fb7-e86f4dce755b
openstack port delete 8f4451e4-02e1-43e7-a221-51df0d4577e6
nova show a812e8cf-d814-410c-9fb7-e86f4dce755b
openstack subnet create --network pentachord-2 --subnet-range 192.168.0.0/16 --dhcp pentachord-192
openstack subnet list
openstack router list | grep penta
openstack route show aabafb22-474b-4e54-a44c-b83020c3b156
openstack port delete 47f04538-adba-4a9d-b405-a362dc13854dA
openstack router remove
openstack router remove port ]
openstack router remove port
openstack router remove port aabafb22-474b-4e54-a44c-b83020c3b156
openstack router remove port aabafb22-474b-4e54-a44c-b83020c3b156 47f04538-adba-4a9d-b405-a362dc13854d
openstack route show aabafb22-474b-4e54-a44c-b83020c3b156
openstack route
openstack router add subnet
openstack subnet list | grep penta
openstack route show aabafb22-474b-4e54-a44c-b83020c3b156
history | grep show
openstack route show aabafb22-474b-4e54-a44c-b83020c3b156
history | grep show
nova show a812e8cf-d814-410c-9fb7-e86f4dce755b
openstack network list
history | grep net
openstack network show pentachord-2
history | grep "subnet create"
nova show a812e8cf-d814-410c-9fb7-e86f4dce755b
openstack server network add a812e8cf-d814-410c-9fb7-e86f4dce755b 650474fa-e660-4098-9918-59dc29545ce8
openstack server add network  a812e8cf-d814-410c-9fb7-e86f4dce755b 650474fa-e660-4098-9918-59dc29545ce8
nova show a812e8cf-d814-410c-9fb7-e86f4dce755b
openstack network show pentachord-2
openstack network show penta

openstack port -h
openstack port unset -h
openstack port delete
openstack port delete -h
openstack port delete --help
openstack port delete --fixed-ip subnet=255.255.0.0,ip-address=172.16.0.10
openstack port delete --fixed-ip subnet=255.255.0.0, ip-address=172.16.0.10
openstack port list | grep 172.16.0.10
openstack port unset 8f4451e4-02e1-43e7-a221-51df0d4577e6
nova show a812e8cf-d814-410c-9fb7-e86f4dce755b
openstack port delete 8f4451e4-02e1-43e7-a221-51df0d4577e6
nova show a812e8cf-d814-410c-9fb7-e86f4dce755b
openstack subnet create --network pentachord-2 --subnet-range 192.168.0.0/16 --dhcp pentachord-192
openstack subnet list
openstack router list | grep penta
openstack route show aabafb22-474b-4e54-a44c-b83020c3b156
openstack port delete 47f04538-adba-4a9d-b405-a362dc13854dA
openstack router remove
openstack router remove port ]
openstack router remove port
openstack router remove port aabafb22-474b-4e54-a44c-b83020c3b156
openstack router remove port aabafb22-474b-4e54-a44c-b83020c3b156 47f04538-adba-4a9d-b405-a362dc13854d
openstack route show aabafb22-474b-4e54-a44c-b83020c3b156
openstack route
openstack router add subnet
openstack subnet list | grep penta
openstack route show aabafb22-474b-4e54-a44c-b83020c3b156
history | grep show
openstack route show aabafb22-474b-4e54-a44c-b83020c3b156
history | grep show
nova show a812e8cf-d814-410c-9fb7-e86f4dce755b
openstack network list
history | grep net
openstack network show pentachord-2
history | grep "subnet create"
nova show a812e8cf-d814-410c-9fb7-e86f4dce755b
openstack server network add a812e8cf-d814-410c-9fb7-e86f4dce755b 650474fa-e660-4098-9918-59dc29545ce8
openstack server add network  a812e8cf-d814-410c-9fb7-e86f4dce755b 650474fa-e660-4098-9918-59dc29545ce8
nova show a812e8cf-d814-410c-9fb7-e86f4dce755b
openstack network show pentachord-2
openstack network show penta
