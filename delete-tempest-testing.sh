#!/bin/bash

for pool in $(neutron lbaas-pool-list | tail -n +4 | head -n -1 | awk '{print $2}')
do
    neutron lbaas-pool-delete $pool
done

for listener in $(neutron lbaas-listener-list | tail -n +4 | head -n -1 | awk '{print $2}')
do
    neutron lbaas-listener-delete $listener
done

for loadbalancer in $(neutron lbaas-loadbalancer-list | tail -n +4 | head -n -1 | awk '{print $2}')
do
    neutron lbaas-loadbalancer-delete $loadbalancer
done

for project in $(openstack project list | tail -n +4 | head -n -1 | awk '{print $2}')
do
    project_name=$(openstack project show $project | grep name | awk '{print $4}')
    if [[ $project_name == tempest* ]]
    then
        echo "deleting stranded project $project_name from OpenStack"
        openstack project delete $project
        partition_name="Project_$project_name"
        echo "deleting stranded partition $partition_name from BIG-IP"
        python -m f5_openstack_agent/utils/clean_partition --config-file ./etc/f5-agent.conf --partition $partition_name
    else
        echo "ignoring project $project_name
