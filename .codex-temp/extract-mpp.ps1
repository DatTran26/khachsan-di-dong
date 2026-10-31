$ErrorActionPreference = 'Stop'

$mppPath = 'C:\Users\ACER\Desktop\Nhom_5_KS_DIDong\KhachSanSach.mpp'
$outputPath = 'D:\Projects\KhachSanDiDong\.codex-temp\mpp-tasks.json'

$app = $null
$project = $null

function Get-ComProperty {
    param(
        [Parameter(Mandatory)] $Object,
        [Parameter(Mandatory)] [string] $Name
    )
    $value = $Object.GetType().InvokeMember(
        $Name,
        [Reflection.BindingFlags]::GetProperty,
        $null,
        $Object,
        $null
    )
    return $value
}

function Get-ComItem {
    param(
        [Parameter(Mandatory)] $Collection,
        [Parameter(Mandatory)] [int] $Index
    )
    $value = $Collection.GetType().InvokeMember(
        'Item',
        [Reflection.BindingFlags]::GetProperty,
        $null,
        $Collection,
        @($Index)
    )
    return $value
}

function Release-ComObjectSafely {
    param($Object)
    if ($null -eq $Object) { return }
    try { [System.Runtime.InteropServices.Marshal]::ReleaseComObject($Object) | Out-Null } catch { }
}

try {
    Add-Type -AssemblyName Microsoft.VisualBasic
    $app = [Microsoft.VisualBasic.Interaction]::GetObject('', 'MSProject.Application')
    $project = $app.GetType().InvokeMember('ActiveProject', [Reflection.BindingFlags]::GetProperty, $null, $app, $null)

    $calendar = $project.GetType().InvokeMember('Calendar', [Reflection.BindingFlags]::GetProperty, $null, $project, $null)
    $tasksCollection = $project.GetType().InvokeMember('Tasks', [Reflection.BindingFlags]::GetProperty, $null, $project, $null)
    $taskCount = Get-ComProperty $tasksCollection 'Count'
    $meta = [ordered]@{
        Name = Get-ComProperty $project 'Name'
        Title = Get-ComProperty $project 'Title'
        StartDate = Get-ComProperty $project 'ProjectStart'
        FinishDate = Get-ComProperty $project 'ProjectFinish'
        CurrentDate = Get-ComProperty $project 'CurrentDate'
        ScheduleFromStart = Get-ComProperty $project 'ScheduleFromStart'
        HoursPerDay = Get-ComProperty $project 'HoursPerDay'
        HoursPerWeek = Get-ComProperty $project 'HoursPerWeek'
        DaysPerMonth = Get-ComProperty $project 'DaysPerMonth'
        DefaultCalendar = if ($calendar) { Get-ComProperty $calendar 'Name' } else { $null }
        TaskCount = $taskCount
    }

    $tasks = for ($index = 1; $index -le $taskCount; $index++) {
        $task = $tasksCollection.GetType().InvokeMember('Item', [Reflection.BindingFlags]::GetProperty, $null, $tasksCollection, @($index))
        if ($null -eq $task) { continue }
        [ordered]@{
            ID = Get-ComProperty $task 'ID'
            OutlineNumber = Get-ComProperty $task 'OutlineNumber'
            OutlineLevel = Get-ComProperty $task 'OutlineLevel'
            Name = Get-ComProperty $task 'Name'
            DurationMinutes = [double](Get-ComProperty $task 'Duration')
            Start = Get-ComProperty $task 'Start'
            Finish = Get-ComProperty $task 'Finish'
        }
        if (($index % 20) -eq 0) { Write-Output "Read $index/$taskCount tasks" }
    }

    [ordered]@{ Meta = $meta; Tasks = @($tasks) } |
        ConvertTo-Json -Depth 6 |
        Set-Content -LiteralPath $outputPath -Encoding utf8
    Write-Output $outputPath
}
finally {
    Release-ComObjectSafely $project
    Release-ComObjectSafely $app
    [gc]::Collect()
    [gc]::WaitForPendingFinalizers()
}
