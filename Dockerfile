FROM centos:7.3.1611
MAINTAINER John Gruber "j.gruber@f5.com"

# add the CentOS Mitaka repo
RUN yum -y install centos-release-openstack-mitaka

# get centos to install all the openstack clients, git, and pip 
RUN yum -y install openstack-tempest git python-pip
# the zaqar client test are broken in RPMs for Mitaka, simply remove them
# this will also remove openstack-tempest which we will be installing a newer
# version from pip
RUN yum -y erase openstack-zaqar 

# get the most recent Mitaka neutron-lbaas from the community github
RUN git clone -b stable/mitaka https://github.com/openstack/neutron-lbaas.git

# allow pip testing depedancies for the latest Mitaka neutron-lbaas tests
RUN pip install -r /neutron-lbaas/neutron_lbaas/tests/tempest/requirements.txt

# the community test try to use 127.0.0.1 as a pool member which is foolishness
# most of these tests are 'negative' tests, but the BIG-IP will not allow 
# pool members on the local host address - it's a gateway afterall
RUN find ./neutron-lbaas/neutron_lbaas/tests/tempest -exec sed -i 's/127.0.0.1/128.0.0.1/g' {} \;

# create a testing environment
RUN tempest init cloudtest
# move the proper version of the community tests into the environment
RUN mv /neutron-lbaas/neutron_lbaas /cloudtest/
# clone the prover version of tempest into the test environment
RUN cp -R /usr/lib/python2.7/site-packages/tempest /cloudtest/
# update global tempest executable to add better testing processing
RUN git clone https://github.com/openstack/tempest.git
RUN pip install /tempest/

# copy standard configurations to the docker image
COPY dot_testr.conf /cloudtest/.testr.conf
COPY f5-agent.conf /cloudtest/etc/
COPY tempest.conf /cloudtest/etc/

# we will download the f5-openstack-agent to use for any testing cleanup on the BIG-IPs
RUN git clone -b mitaka https://github.com/F5Networks/f5-openstack-agent.git
RUN pip install /f5-openstack-agent/
RUN rm -rf /f5-openstack-agent

# create an helper script to clean up OpenStack and the BIG-IP after testing
RUN mkdir /cloudtest/tools/
COPY tools/clean-os-from-testing.sh /cloudtest/tools/clean-os-from-testing.sh
RUN chmod +x /cloudtest/tools/clean-os-from-testing.sh
COPY tools/clean_bigip.py /cloudtest/tools/clean_bigip.py
COPY tools/clean-bigip-from-testing.sh /cloudtest/tools/clean-bigip-from-testing.sh
RUN chmod +x /cloudtest/tools/clean-bigip-from-testing.sh
COPY tools/clean /cloudtest/tools/clean
RUN chmod +x /cloudtest/tools/clean
COPY tools/populate-conf-from-env /cloudtest/tools/populate-conf-from-env
RUN chmod +x /cloudtest/tools/populate-conf-from-env

CMD /bin/bash 

