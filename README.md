# neutron_lbaas_v2_tester
Tempest install to manually run OpenStack neutron_lbaas V2 tests

CentOS 7.3 based installation of Tempest for OpenStack Mitaka

Run docker build from the Docker file.

```
  git clone https://github.com/jgruber/neutron_lbaas_v2_tester.git
  docker build -t neutron_lbaas_v2_tester ./neutron_lbaas_v2_tester
```

#### Run an interactive docker container ####

```
  docker run -t -i --name neutron_lbaas_v2_tester neutron_lbaas_v2_tester /bin/bash
```

#### Edit test setup ####
```
  cd /cloudtest
  vi ./etc/tempest.conf 
  vi ./etc/f5-agent.conf
```

You will need to add your OpenStack controller address and credentials in the tempest.conf file.

Optionally you will need to add your BIG-IP iControl endpoint hostname and credemtials in the f5-agent.conf

#### Run tests ####
```
  testr list-tests
  testr neutron_lbaas.tests.tempest.v2.api.test_load_balancers_non_admin.LoadBalancersTestJSON.test_get_load_balancer
  tempest run
  tempest run --regex '^neutron_lbaas.test.tempest.v2.api'
```

