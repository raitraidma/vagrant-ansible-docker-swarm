#!/bin/bash

ansible-playbook playbook.yml -i inventory -e @vars.yml
