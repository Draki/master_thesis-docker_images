# master_thesis-docker_images

To deploy hibrid environment:

    powershell -executionpolicy bypass -File .\infrastructure\Hibrid-environment\swarm-setup.ps1
    ...(Wait until it gets deployed)...
    powershell -executionpolicy bypass -File .\thesisAppTesting\swarm-appLauncher-hibrid.ps1

To deploy hyper-v environment:

    powershell -executionpolicy bypass -File .\infrastructure\HypervVMs-environment\swarm-setup.ps1
    ...(Wait until it gets deployed)...
    powershell -executionpolicy bypass -File .\thesisAppTesting\swarm-appLauncher-hyperv.ps1