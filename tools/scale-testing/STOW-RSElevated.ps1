﻿$CurrentDirectory = ($pwd).path

$CommonModule = -join($CurrentDirectory, '\', 'Common.psm1')
Import-Module $CommonModule -Force

$txt = '.txt'

$ResourceGroup = Read-Host -Prompt 'Input resource group name'
$Namespace = Read-Host -Prompt 'Input Service Bus Namespace name'
$InstanceCount = Read-Host -Prompt 'Input total count of instances'
$ConcurrentThreads = Read-Host -Prompt 'Input threads to run simultaneously for upload'

$AppName = Read-Host -Prompt 'Input App Service Name'

$InstanceCountPerThread = $InstanceCount / $ConcurrentThreads
$PersonGeneratorProject = -join($CurrentDirectory, '\Microsoft.Health.Dicom.Tools.ScaleTesting.PersonInstanceGenerator')
$PersonGeneratorApp = -join ($PersonGeneratorProject, '\bin\Release\netcoreapp3.1\Microsoft.Health.Dicom.Tools.ScaleTesting.PersonInstanceGenerator')
$PatientNames = -join($CurrentDirectory, '\PatientNames.txt')
$PhysicianNames = -join($CurrentDirectory, '\PhysicianNames.txt')

build($PersonGeneratorProject)
for($i = 0; $i -lt $ConcurrentThreads; $i++)
{
	$fileName = -join($CurrentDirectory, '\', $i, $txt)
	Start-Process -FilePath $PersonGeneratorApp -ArgumentList "$PatientNames, $PhysicianNames, $fileName, $InstanceCountPerThread"
}

$SubscriptionState = Get-AzServiceBusSubscription -ResourceGroup $ResourceGroup -NamespaceName $Namespace -TopicName 'stow-rs' -SubscriptionName 's1'
while($SubscriptionState.properties.messageCount -lt $InstanceCount)
{
    Start-Sleep -s 60
    $SubscriptionState = Get-AzServiceBusSubscription -ResourceGroup $ResourceGroup -NamespaceName $Namespace -TopicName 'stow-rs' -SubscriptionName 's1'
}

Start-Sleep -s 120

$MessageHandlerProject = -join($CurrentDirectory, '\Microsoft.Health.Dicom.Tools.ScaleTesting.MessageHandler')

build($MessageHandlerProject)
createPackage($MessageHandlerProject)
deploy -resourceGroupName $ResourceGroupName -appName $AppName -basepath $MessageHandlerProject