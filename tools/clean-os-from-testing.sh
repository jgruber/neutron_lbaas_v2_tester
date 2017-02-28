#!/bin/bash

echo "Cleaning Nova Instances"
for instance in $(nova list --all-tenants | tail -n +4 | head -n -1 | awk '{print $2}')
do
    is_tempest=$(nova show 57b3c194-5f3a-415f-8328-625f55297aa7|grep tempest|wc -l)
    if [[ $is_tempest ]]
    then
       nova delete $instance
    fi
done

echo "Cleaning Security Groups"
for secgroup in $(neutron security-group-list|grep tempest|awk '{print $2}')
do
    neutron security-group-delete $secgroup
done

echo "Cleaning Routers"
for router in $(neutron router-list|grep tempest|awk '{print $2}')
do
    neutron router-port-list $router|grep subnet_id|while read line; do subnet_id=$(echo $line|awk 'BEGIN { FS="\"";}{print $4}'); neutron router-interface-delete $router $subnet_id; done
    neutron router-delete $router
done

echo "Cleaning Pools"
for pool in $(neutron lbaas-pool-list | tail -n +4 | head -n -1 | awk '{print $2}')
do
    neutron lbaas-pool-delete $pool
done

echo "Cleaning Listeners"
for listener in $(neutron lbaas-listener-list | tail -n +4 | head -n -1 | awk '{print $2}')
do
    neutron lbaas-listener-delete $listener
done

echo "Cleaning Loadbalacners"
for loadbalancer in $(neutron lbaas-loadbalancer-list | tail -n +4 | head -n -1 | awk '{print $2}')
do
    neutron lbaas-loadbalancer-delete $loadbalancer
done

echo "Cleaning Networks and Subnets"
for network in $(neutron net-list | tail -n +4 | head -n -1 | awk '{print $2}')
do
    network_name=$(neutron net-show $network | grep name | awk '{print $4}')
    subnets_id=$(neutron net-show $network | grep subnets | awk '{print $4}')
    if [[ $network_name == tempest* || $network_name == network-* ]]
    then  
        neutron port-list|grep $subnets_id|while read line ; do port_id=$(echo $line|awk '{print $2}'); neutron port-delete $port_id; done
        neutron subnet-delete $subnets_id
        neutron net-delete $network
    fi
done

echo "Cleaning Projects"
for project in $(openstack project list | tail -n +4 | head -n -1 | awk '{print $2}')
do
    project_name=$(openstack project show $project | grep name | awk '{print $4}')
    if [[ $project_name == tempest* ]]
    then
        echo "deleting stranded project $project_name from OpenStack"
        openstack project delete $project
    else
        echo "ignoring project $project_name"
    fi
done

