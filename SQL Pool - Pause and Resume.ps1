function Manage-SynapseSqlPools {
    param (
        [string]$resourceGroupName,
        [string]$workspaceName,
        [string]$sqlPoolName
    )

    $statusMessages = @()

    try {
        Write-Output "Logging in to Azure..."
        Connect-AzAccount -Identity

        $SynapseSqlPool = Get-AzSynapseSqlPool -ResourceGroupName $resourceGroupName -Workspacename $workspaceName -Name $sqlPoolName

        if ($SynapseSqlPool.Status -eq "Paused") {
            Write-Output "Synapse SQL Pool [$($SynapseSqlPool.SqlPoolName)] found with status [Paused]"

              try {
                  $resultsynapseSqlPool = $SynapseSqlPool | Resume-AzSynapseSqlPool -ErrorAction Stop -Confirm:$false
                  $statusMessages += "Resumed SQL Pool [$($SynapseSqlPool.SqlPoolName)] in $($resultsynapseSqlPool.ResumeState)"
              } catch {
                  $errorMessage = "Failed to resume Synapse SQL Pool [$($SynapseSqlPool.SqlPoolName)]: $_"
                  Write-Error $errorMessage
                  $statusMessages += $errorMessage
            #  }
        } elseif ($SynapseSqlPool.Status -eq "Online") {
            Write-Output "Synapse SQL Pool [$($SynapseSqlPool.SqlPoolName)] found with status [Online]"

            try {
                $resultsynapseSqlPool = $SynapseSqlPool | Suspend-AzSynapseSqlPool -ErrorAction Stop
                $statusMessages += "Paused SQL Pool [$($SynapseSqlPool.SqlPoolName)] in $($resultsynapseSqlPool.PauseState)"
            } catch {
                $errorMessage = "Failed to pause Synapse SQL Pool [$($SynapseSqlPool.SqlPoolName)]: $_"
                Write-Error $errorMessage
                $statusMessages += $errorMessage
            }

            # Code to handle the paused state...
        } elseif ($SynapseSqlPool.Status -eq "Resuming") {
            Write-Output "Synapse SQL Pool [$($SynapseSqlPool.SqlPoolName)] found with status [Resuming]"
            $statusMessages += "SQL Pool [$($SynapseSqlPool.SqlPoolName)] is currently resuming."
        }
    } catch {
        $errorMessage = "Error: $($_.Exception.Message)"
        Write-Error $errorMessage
        $statusMessages += $errorMessage
        throw $_.Exception
    }

    return $statusMessages
}

$resourceGroupName = Get-AutomationVariable -Name "SynapseSQLPool_Resource_Group"
$workspaceName = Get-AutomationVariable -Name "SynapseSQLPool_WorkspaceName"
$sqlPoolName = Get-AutomationVariable -Name "SynapseSQLPool_SqlPoolName"

$finalStatusMessages = Manage-SynapseSqlPools -resourceGroupName $resourceGroupName -workspaceName $workspaceName -sqlPoolName $sqlPoolName

# Output the final status
$finalStatusMessages
