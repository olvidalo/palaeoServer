xquery version "3.0";

module namespace activity="http://xpalaeo.mts.aldebaran.uberspace.de/activity";
import module namespace config="http://xpalaeo.mts.aldebaran.uberspace.de/config" at "config.xqm";
declare namespace tei="http://www.tei-c.org/ns/1.0";

declare option exist:serialize "method=json media-type=text/javascript";

declare variable $activity:public-app-root := doc($config:app-root||"/conf.xml")/app-conf/webapp-root/text();

declare function activity:generate-metadata($res as xs:string) {
  let $tei := doc($config:app-root || "/data/tei/" || $res)
  let $title := string-join(($tei//tei:idno, $tei//tei:title[not(.="")]), "; ")
  return <activity>
            <name>
                <en-US>{$title}</en-US>
            </name>
            <description>
                <en-US>Papyrus '{$title}' aus der Kölner Papyrussammlung.</en-US>
            </description>
        </activity>
};

declare function activity:activities() {
      for $tei in collection($config:app-root || "/data/tei")//tei:TEI[not(.//tei:text="")]
      let $title := string-join(($tei//tei:idno, $tei//tei:title[not(.="")]), "; ")
      let $link := request:get-scheme()||"://"||request:get-server-name()||":"||request:get-server-port()||$activity:public-app-root||'/data/tei/'||util:document-name($tei)
      return <activities>
            <activity>
            <id>{$link}</id>
            <definition>
               <name>
                   <en-US>{$title}</en-US>
               </name>
               <description>
                   <en-US>Papyrus '{$title}' aus der Kölner Papyrussammlung.</en-US>
               </description>            
                
            </definition>
            </activity>
              
          </activities>
};