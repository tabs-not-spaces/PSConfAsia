#region configuration
# POST method: $req
$requestBody = Get-Content $req -Raw | ConvertFrom-Json
$name = $requestBody.name

# GET method: each querystring parameter is its own variable
if ($req_query_blog) 
{
    [string[]]$reqBody = $req_query_blog
}
else {
    $reqBody = "blog.vigilant.it", "powers-hell.com", "steven.hosking.com.au"
}
#endregion
#region main process
$posts = (Invoke-RestMethod -UseBasicParsing -Method Get -Uri "https://gist.githubusercontent.com/erikcox/7e96d031d00d7ecb1a2f/raw/0c24948e031798aacf45fd8b7207c45d8e41a373/SimCityLoadingMessages.txt").split("`r`n")
$randomPost = [PSCustomObject]@{
    Post = (Get-Random $posts)
}
#endregion
#region output
$randomPost | ConvertTo-Json -Depth 10 -Compress | Out-File -Encoding Ascii -FilePath $res
#endregion
