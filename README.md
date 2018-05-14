# master_thesis-docker_images

Hibrid environment
------------------
>To deploy:

    powershell -executionpolicy bypass -File .\infrastructure\Hibrid-environment\swarm-setup.ps1
    ...(Wait until it gets deployed)...
    powershell -executionpolicy bypass -File .\thesisAppTesting\swarm-appLauncher-hibrid.ps1

>To clean-up:

    powershell -executionpolicy bypass -File .\infrastructure\Hibrid-environment\swarm-teardown.ps1
    
   
Hyper-v environment
-------------------
>To deploy:
          
    powershell -executionpolicy bypass -File .\infrastructure\HypervVMs-environment\swarm-setup.ps1
    ...(Wait until it gets deployed)...
    powershell -executionpolicy bypass -File .\thesisAppTesting\swarm-appLauncher-hyperv.ps1

>To clean-up:

    powershell -executionpolicy bypass -File .\infrastructure\HypervVMs-environment\swarm-teardown.ps1
    
