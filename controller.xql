xquery version "3.0";

import module namespace activity="http://xpalaeo.mts.aldebaran.uberspace.de/activity" at "modules/activity.xqm";
import module namespace user="http://xpalaeo.mts.aldebaran.uberspace.de/user" at "modules/user.xql";
import module namespace config="http://xpalaeo.mts.aldebaran.uberspace.de/config" at "modules/config.xqm";


declare variable $local:app-root := $config:app-root;
declare variable $local:file-path := $config:app-root;


declare variable $exist:path external;
declare variable $exist:resource external;
declare variable $exist:controller external;
declare variable $exist:prefix external;
declare variable $exist:root external;

let $headers := (response:set-header("Access-Control-Allow-Origin", "*"), response:set-header("Access-Control-Allow-Headers", "accept,content-type,authorization"))

let $response :=



if (request:get-method() = "OPTIONS") then <null/>  

else if (ends-with($exist:resource, ".xml")) then
     if (request:get-header("Accept") eq "application/json") then 
         (util:declare-option("exist:serialize", "method=json media-type=application/json"), activity:generate-metadata($exist:resource))
     else 
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <cache-control cache="yes"/>
        <forward url="{$exist:resource}">
            <set-header name="Access-Control-Allow-Origin" value="*"/>
            <set-header name="Access-Control-Allow-Headers" value="accept,content-type,authorization"/>
        </forward>
    </dispatch>

 else  if ($exist:path eq "/user/login") then user:user('login') 
else if ($exist:path eq "/user") then user:user('getuser')
else if ($exist:path eq "/users") then user:user('get_users')
else if (request:get-method() = "POST" and $exist:path eq "/user/preferences") then user:user('save_prefs')
else if (request:get-method() = "GET" and $exist:path eq "/user/preferences") then user:user('get_prefs')

else if ($exist:path eq '') then
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <redirect url="{request:get-uri()}/"/>
    </dispatch>
    
else if ($exist:path eq "/") then
    (: forward root path to index.xql :)
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <redirect url="index.html"/>
    </dispatch>

else if (ends-with($exist:path, "exercises")) then 
    (util:declare-option("exist:serialize", "method=json media-type=application/json"), <items>{activity:activities()}</items>)
         
    
else if (ends-with($exist:resource, ".html")) then
    (: the html page is run through view.xql to expand templates :)
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <view>
            <forward url="{$exist:controller}/modules/view.xql"/>
        </view>
		<error-handler>
			<forward url="{$exist:controller}/error-page.html" method="get"/>
			<forward url="{$exist:controller}/modules/view.xql"/>
		</error-handler>
    </dispatch>
(: Resource paths starting with $shared are loaded from the shared-resources app :)
else if (contains($exist:path, "/$shared/")) then
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <forward url="/shared-resources/{substring-after($exist:path, '/$shared/')}">
            <set-header name="Cache-Control" value="max-age=3600, must-revalidate"/>
        </forward>
    </dispatch>
else
    (: everything else is passed through :)
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <cache-control cache="yes"/>
        <forward url="{$exist:resource}">
            <set-header name="Access-Control-Allow-Origin" value="*"/>
            <set-header name="Access-Control-Allow-Headers" value="accept,content-type,authorization"/>
        </forward>
    </dispatch>
    
 return $response
