#region configuration
# POST method: $req
$requestBody = Get-Content $req -Raw | ConvertFrom-Json
$name = $requestBody.name

# GET method: each querystring parameter is its own variable
if ($req_query_blog) {
    [string[]]$blogs = $req_query_blog
}
else {
    $blogs = "blog.vigilant.it", "powers-hell.com", "steven.hosking.com.au"
}
#endregion
#region functions
function Get-WordPressPostSummary {
    [CmdletBinding()]
    param (
        [string[]]$url
    )
    try {
        $result = @()
        foreach ($blog in $url) {
            $hostName = $blog -replace '(^http:\/\/)|(\/$)', ''
            try {
                $iwr = Invoke-WebRequest -Method Get -UseBasicParsing `
                    -Uri "http://$($hostName)/wp-json/wp/v2/posts"
                
            }
            catch {
                $iwr = Invoke-WebRequest -Method Get -UseBasicParsing `
                    -Uri "http://$($hostName)/?rest_route=/wp/v2/posts"
            }
            if ($iwr.StatusCode -eq 200) {
                $jsonContent = $iwr.Content | ConvertFrom-Json
                foreach ($post in $jsonContent) {
                    $result += [PSCustomObject]@{
                        Date    = get-date $($post.date)
                        Site    = $blog
                        Link    = [System.Web.HttpUtility]::HtmlDecode($post.link)
                        Title   = [System.Web.HttpUtility]::HtmlDecode($post.title.rendered)
                        Excerpt = [System.Web.HttpUtility]::HtmlDecode($post.excerpt.rendered) `
                            -replace '\<\/?.*?\>', ""
                    }
                }
            }
        }
        if ($result) {
            return $result | Sort-Object -Property Date -Descending
        }
        else {
            Throw $iwr.StatusCode
        }
    }
    catch {
        Write-Warning $_.Exception.Message
    }
}
#endregion
#region main process
$postReturn = Get-WordPressPostSummary -url $blogs | ConvertTo-Json -Depth 20
#endregion
#region output
$postReturn | Out-File -Encoding Ascii -FilePath $res
#endregion
