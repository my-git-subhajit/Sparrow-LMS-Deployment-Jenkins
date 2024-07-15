#!/bin/bash
# Update the GRUB configuration
echo 'GRUB_CMDLINE_LINUX="systemd.unified_cgroup_hierarchy=0"' | sudo tee -a /etc/default/grub

# Update GRUB and reboot
sudo grub2-mkconfig -o /boot/grub2/grub.cfg
sudo reboot
