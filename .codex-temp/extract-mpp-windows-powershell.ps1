$ErrorActionPreference = 'Stop'

$outputPath = 'D:\Projects\KhachSanDiDong\.codex-temp\mpp-tasks.json'
$app = [Runtime.InteropServices.Marshal]::GetActiveObject('MSProject.Application')
$project = $app.ActiveProject

$meta = [ordered]@{
    Name = $project.Name
    Title = $project.Title
    StartDate = $project.ProjectStart
    FinishDate = $project.ProjectFinish
    CurrentDate = $project.CurrentDate
    ScheduleFromStart = $project.ScheduleFromStart
    HoursPerDay = $project.HoursPerDay
    HoursPerWeek = $project.HoursPerWeek
    DaysPerMonth = $project.DaysPerMonth
    DefaultCalendar = $project.Calendar.Name
    TaskCount = $project.Tasks.Count
}

$rows = New-Object System.Collections.Generic.List[object]
for ($index = 1; $index -le $project.Tasks.Count; $index++) {
    $task = $project.Tasks.Item($index)
    if ($null -eq $task) { continue }

    $rows.Add([ordered]@{
        ID = $task.ID
        UniqueID = $task.UniqueID
        WBS = $task.WBS
        OutlineNumber = $task.OutlineNumber
        OutlineLevel = $task.OutlineLevel
        Name = $task.Name
        Summary = $task.Summary
        Milestone = $task.Milestone
        DurationMinutes = [double]$task.Duration
        WorkMinutes = [double]$task.Work
        Start = $task.Start
        Finish = $task.Finish
        Predecessors = $task.Predecessors
        PercentComplete = $task.PercentComplete
        Notes = $task.Notes
    })
}

[ordered]@{ Meta = $meta; Tasks = $rows } |
    ConvertTo-Json -Depth 6 |
    Set-Content -LiteralPath $outputPath -Encoding utf8

[Runtime.InteropServices.Marshal]::ReleaseComObject($project) | Out-Null
[Runtime.InteropServices.Marshal]::ReleaseComObject($app) | Out-Null
Write-Output $outputPath
