xquery version "3.0";
module namespace user="http://xpalaeo.mts.aldebaran.uberspace.de/user";
import module namespace xqjson="http://xqilla.sourceforge.net/lib/xqjson";
import module namespace console="http://exist-db.org/xquery/console";
import module namespace config="http://xpalaeo.mts.aldebaran.uberspace.de/config" at "modules/config.xqm";


declare function user:user($action as xs:string) {
   let $serialization := util:declare-option("exist:serialize", "method=json media-type=application/json")
   let $requestData := request:get-data()
   let $data := if (empty($requestData)) then "" else  xqjson:parse-json(util:binary-to-string(request:get-data())) 
   let $log := console:log($data)
   return switch($action)
            case 'login' return <result>{xmldb:get-current-user()}</result>
            case 'getuser' return <result><user>{xmldb:get-current-user()}</user><metadata>{sm:get-account-metadata-keys(xmldb:get-current-user())}</metadata></result>
            case 'get_users' return  <result>{
                                            for $user in sm:get-group-members("students")
                                            let $prefs := doc($config:app-root||"/data/user/"||$user||".xml")/preferences
                                            return  <users>
                                                         <name>{$user}</name>
                                                         <mbox>mailto:{$prefs/email/text()}</mbox>
                                                    </users>
                                        }</result>
            case 'get_prefs' return <preferences>{(
                                        doc($config:app-root||"/data/user/"||xmldb:get-current-user()||".xml")/preferences,
                                        <group>{
                                            if (xmldb:get-user-groups(xmldb:get-current-user()) = "teachers") then "teachers" else "students" 
                                        }</group>
                                    )}</preferences>
            case 'save_prefs' return   let $prefs := <preferences>
                                                        <email>{$data//pair[@name="email"]/text()}</email>
                                                        <lrsEndpoint>{$data//pair[@name="lrsEndpoint"]/text()}</lrsEndpoint>
                                                        <lrsUser>{$data//pair[@name="lrsUser"]/text()}</lrsUser>
                                                        <lrsPassword>{$data//pair[@name="lrsPassword"]/text()}</lrsPassword>
                                                     </preferences> 
                                       let $logg := console:log($prefs)
                                       let $save := user:set-preferences(xmldb:get-current-user(), $prefs)
                                       return <preferences>{$prefs}</preferences>

            
            default return <error/>
};

declare function user:set-preferences($user as xs:string, $prefs as element(preferences)) {
  let $currentPrefs := if (not(doc-available($config:app-root||"/data/user/"||$user||".xml"))) then
                            let $preferences := <preferences/>
                            let $store := xmldb:store($config:app-root||"/data/user/", $user||".xml", $preferences)
                            return $preferences
                        else doc($config:app-root||"/data/user/"||$user||".xml")/preferences
   return  update value doc($config:app-root||"/data/user/"||$user||".xml")/preferences with $prefs/*
                        
};