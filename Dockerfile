FROM centos:7.3.1611
MAINTAINER John Gruber "j.gruber@f5.com"

RUN yum -y install centos-release-openstack-mitaka
RUN yum -y install openstack-tempest git python-pip
RUN yum -y erase openstack-zaqar 
RUN git clone http://git.openstack.org/openstack/tempest
RUN git clone https://github.com/openstack/neutron-lbaas.git
RUN git clone https://github.com/F5Networks/f5-openstack-agent.git
RUN pip install /tempest/
RUN pip install /f5-openstack-agent/
RUN rm -rf /f5-openstack-agent
RUN tempest init cloudtest
RUN mv /neutron-lbaas/neutron_lbaas /cloudtest/
RUN mv /tempest/tempest /cloudtest/
RUN rm -rf /tempest
RUN rm -rf /neutron-lbaas
COPY dot_testr.conf /cloudtest/.testr.conf
COPY delete-tempest-testing.sh /cloudtest/
RUN chmod +x /cloudtest/delete-tempest-testing.sh
RUN sed -i 's/return sh.purge_folder_contents(bigip, folder=partition)/sh\.purge_folder_contents(bigip, folder=partition)\n    return sh.delete_folder(bigip, partition)\n'/ /usr/lib/python2.7/site-packages/f5_openstack_agent/utils/clean_partition.py
COPY f5-agent.conf /cloudtest/etc/
COPY tempest.conf /cloudtest/etc/
RUN /bin/bash 

