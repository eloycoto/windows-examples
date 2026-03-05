# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "peru/windows-server-2022-standard-x64-eval"
  config.vm.hostname = "x2a-windows"
  config.vm.guest = :windows

  # WinRM communicator (required for Windows guests; plaintext is fine for local dev)
  config.vm.communicator = "winrm"
  config.winrm.username = "vagrant"
  config.winrm.password = "vagrant"
  config.winrm.transport = :plaintext
  config.winrm.basic_auth_only = true
  config.vm.boot_timeout = 600

  # Port forwarding
  config.vm.network "forwarded_port", guest: 80,   host: 8080,  id: "http"
  config.vm.network "forwarded_port", guest: 443,  host: 8443,  id: "https"
  config.vm.network "forwarded_port", guest: 3389, host: 33389, id: "rdp"

  # Libvirt provider
  config.vm.provider "libvirt" do |libvirt|
    libvirt.memory = 4096
    libvirt.cpus = 2
  end

  # Create target directory, then copy config files into the VM.
  # The file provisioner cannot create directories with drive-letter paths directly.
  config.vm.provision "shell", inline: "New-Item -Path 'C:\\dsc-configs' -ItemType Directory -Force"
  config.vm.provision "file",
    source: "configs",
    destination: "C:\\dsc-configs\\configs"

  # Run provisioning script
  config.vm.provision "shell",
    path: "vagrant-provision.ps1",
    privileged: true
end
