<?php
// fit to fake data handler
// data.php?c=cat,cat,cat,cat,...
// can take different categories. I shold be able to have different source beyond the nyt.
// 
// first: see if the data are cached. there's a cache time, like every hour.
// cached data is kept in files or a db per category.
// if cached serve the json and quit. 
// if not, fetch, insert, serve
// it may be easiest to get a lot of data from the API and insert it. 
// the default tweets can also be served.
// if there is no connection to API, it  should still run from cache. 
//
//SECRETS
//$_SERVER;
//print("<pre>");
//print_r($GLOBALS);
//print("</pre>");

$nytApiKey ="iPqYn6jBHAARoKYPLvAVEZSZx1mAlq1G";
$newsAPIKey = "5cd8e1874eb6443588a3bfd309439ee2";

//https://api.nytimes.com/svc/topstories/v2/\(section).json?api-key=\(apiKey)"

$database = "F2F/f2f.db";
$db = new SQLite3($database,SQLITE3_OPEN_READWRITE);

$cacheExpireSeconds = 5;//60*60;
//$db->open('R');


/**
* Curl send get request, support HTTPS protocol
* @param string $url The request url
* @param string $refer The request refer
* @param int $timeout The timeout seconds
* @return mixed
*/
function getRequest($url, $refer = "", $timeout = 10)
{
    $ssl = stripos($url,'https://') === 0 ? true : false;
    $curlObj = curl_init();
    $options = array(
    	CURLOPT_URL => $url,
        CURLOPT_RETURNTRANSFER => 1,
        CURLOPT_FOLLOWLOCATION => 1,
        CURLOPT_AUTOREFERER => 1,
        CURLOPT_USERAGENT => 'Mozilla/5.0 (compatible; MSIE 5.01; Windows NT 5.0)',
        CURLOPT_TIMEOUT => $timeout,
        CURLOPT_HTTP_VERSION => CURL_HTTP_VERSION_1_0,
        CURLOPT_HTTPHEADER => array('Expect:'),
        CURLOPT_IPRESOLVE => CURL_IPRESOLVE_V4,
    );
    if ($refer) {
        $options[CURLOPT_REFERER] = $refer;
    }
    if ($ssl) {
        //support https
        $options[CURLOPT_SSL_VERIFYHOST] = false;
        $options[CURLOPT_SSL_VERIFYPEER] = false;
    }
    curl_setopt_array($curlObj, $options);
    $returnData = curl_exec($curlObj);
    if (curl_errno($curlObj)) {
        //error message
        $returnData = curl_error($curlObj);
    }
    curl_close($curlObj);
    return $returnData;
}

/**
* Curl send post request, support HTTPS protocol
* @param string $url The request url
* @param array $data The post data
* @param string $refer The request refer
* @param int $timeout The timeout seconds
* @param array $header The other request header
* @return mixed
*/
function postRequest($url, $data, $refer = "", $timeout = 10, $header = array())
{
    $curlObj = curl_init();
    $ssl = stripos($url,'https://') === 0 ? true : false;
    $options = array(
        CURLOPT_URL => $url,
        CURLOPT_RETURNTRANSFER => 1,
        CURLOPT_POST => 1,
        CURLOPT_POSTFIELDS => $data,
        CURLOPT_FOLLOWLOCATION => 1,
        CURLOPT_AUTOREFERER => 1,
        CURLOPT_USERAGENT => 'Mozilla/5.0 (compatible; MSIE 5.01; Windows NT 5.0)',
        CURLOPT_TIMEOUT => $timeout,
        CURLOPT_HTTP_VERSION => CURL_HTTP_VERSION_1_0,
        CURLOPT_HTTPHEADER => array('Expect:'),
        CURLOPT_IPRESOLVE => CURL_IPRESOLVE_V4,
        CURLOPT_REFERER => $refer
    );
    if (!empty($header)) {
        $options[CURLOPT_HTTPHEADER] = $header;
    }
    if ($refer) {
        $options[CURLOPT_REFERER] = $refer;
    }
    if ($ssl) {
        //support https
        $options[CURLOPT_SSL_VERIFYHOST] = false;
        $options[CURLOPT_SSL_VERIFYPEER] = false;
    }
    curl_setopt_array($curlObj, $options);
    $returnData = curl_exec($curlObj);
    if (curl_errno($curlObj)) {
        //error message
        $returnData = curl_error($curlObj);
    }
    curl_close($curlObj);
    return $returnData;
}

// build a query for a category
// summaries: ID, source, category, last, json data
// last = -1 means don't update.
//$statement = $db->prepare('SELECT * FROM table WHERE id = :id;');
//$statement->bindValue(':id', $id);

$catmapq =$db->prepare('SELECT * from cmap where ccode=:cat');
$lastq =$db->prepare('SELECT last from summaries as s where s.source=:src and s.category = :cat');
$summaryq =$db->prepare('SELECT * from summaries as s where s.source=:src and s.category = :cat');
//
$catUIq =$db->prepare('SELECT uiname,ccode from cmap');

//$db->close();
// what categories does a source have?
// what sources are there?

// tables in the db:

 
// get categories 
$get_c = trim($_GET['c']);
$get_d = trim($_GET['d']);

if($get_d)
{
//print("got a d\n");
$catUIq->reset();
$uiresults = $catUIq->execute();

//$uiresults= $db->exec('SELECT uiname,ccode from cmap');
//print($uiresults.numColumns());
$theResult="{";
$comma='';
while ($pair= $uiresults->fetchArray(1))
	{
//			print("<pre> bunch<br>");
//			print_r($pair);
//			print("</pre>");
	$theResult.=$comma;
	$theResult.='"'.$pair["uiname"].'":"'.$pair["ccode"].'"';
	$comma=',';
	}
$theResult.="}";
print( $theResult);
exit();
}
$categories = explode(',',$get_c);
// find out what needs refreshing

foreach($categories as $category)
{
//	print ("CATEGORY:".$category."<br>");
//	$db->open($database,SQLITE3_OPEN_READWRITE);
	$catmapq->reset();
	$bindRes = $catmapq->bindValue(":cat", $category);
	$results = $catmapq->execute();
//	$db->close();
//	print("RESULT for:".$category." columns:".$results->numColumns()." -- ");
// combine all the call results? or only allow one? 
$remember = array();
// Fetch Associated Array (1 for SQLITE3_ASSOC)
	while ($resArray= $results->fetchArray(1))
	{
 		$src = $resArray['source'];
 		$cat = $resArray['category'];
// 		print("MAP:".$src." ->".$cat."<br>");
 		$lastq->reset();
 		$bindRes = $lastq->bindValue(":src", $src);
 		$bindRes = $lastq->bindValue(":cat", $cat);
 		$qlresults = $lastq->execute();
//	print("lasts:".$qlresults->numColumns()." -- <br>");
	// should only be one result . 
	$qlresults->reset();
	while ($lastr= $qlresults->fetchArray(1))
	{
//		print("<pre>");
//		print_r($lastr);
//		print("</pre>");
		$lastTime = $lastr['last'];
//		print("last: ".gettype($lastTime)."<br>");
		if($lastTime>-1)
		{
//			print ("DDD:".time().' ?= '.($lastTime+$cacheExpireSeconds)."<br>");
			if(($lastTime+$cacheExpireSeconds) <time())
			{
				$remember[]=array($src,$cat);
			}
			else
			{
//							print($cat." cache is still good<br>");

			};
		};
 
	}
			 
	}
};
 // now go over the refresh list .. should be able to write to the db is .. I dunno - we close it and open it again. 

 foreach($remember as $triplet)
 {
//	print("Get:".$triplet[0].' '.$triplet[1]);	
	$summaryclear =$db->prepare('DELETE FROM summaries WHERE source=:src AND category =:cat');
	$summaryclear->reset();
	$summaryclear->bindValue(":src", $src);
	$summaryclear->bindValue(":cat", $cat);
	$summaryclear->execute();
		
	// here's where we get it from the actual source
	$theResult = '["this is a '.$src.' test:'.$cat.'","this is a second test:'.$cat.'?"]';

	if($src == 'nyt')
	{
			$theResult = '[';
		$nytData = getRequest("https://api.nytimes.com/svc/topstories/v2/".$cat.".json?api-key=".$nytApiKey);
		$nytobj = json_decode(utf8_encode($nytData),true); // turn into array
//		print("<pre> nytobj<br>");
//		print_r($nytobj);
//		print("</pre>");

		$comma='';
		$bunch = $nytobj['results'];
		foreach($bunch as $result)
		{
//		print("<pre> bunch<br>");
//		print_r($bunch);
//		print("</pre>");
			$theResult.=$comma;
			$abstract = json_encode($result['abstract']);
			$theResult.=$abstract;
			$comma=',';
		}

		$theResult.="]";
	}
	//
	if($src == 'napi')
	{
		// news API
//		https://newsapi.org/v2/everything -G -d q=fake%20news -d sortBy=popularity -d apiKey=5cd8e1874eb6443588a3bfd309439ee2
// https://newsapi.org/v2/everything?q=climate&sortBy=popularity&apiKey=5cd8e1874eb6443588a3bfd309439ee2
		$theResult = '[';
		$napireq = "https://newsapi.org/v2/everything?q=".$cat."&sortBy=popularity&apiKey=".$newsAPIKey;
//		print("NAPIREQ: ".$napireq."<br>");
		$napiData = getRequest($napireq);
		$napiobj = json_decode(utf8_encode($napiData),true); // turn into array
//		print("<pre> napiobj<br>");
//		print_r($napiobj);
//		print("</pre>");

		$comma='';
		$bunch = $napiobj['articles'];
		foreach($bunch as $result)
		{
//		print("<pre> bunch<br>");
//		print_r($bunch);
//		print("</pre>");
		$content = $result['content'];
//		$content=str_replace($content,"\u00e2\u0080\u00a6","...");
//				print("<pre> content, len:".strlen($content)."<br>");
//		print_r($content);
//		print("</pre>");
		if (strlen($content)>5)
		{
			$theResult.=$comma;
			// ?? 
			$abstract = json_encode($content);
			$theResult.=$abstract;
			$comma=',';
		}
		}
		$theResult.="]";
	}

	
//		print("<pre> result of nyt fetch<br>");
//		print $theResult;
//		print("</pre>");
		
	$summaryinsert =$db->prepare('INSERT INTO summaries (source,category,last,data) values(:src,:cat,:last,:data)');
	$summaryinsert->reset();
	$summaryinsert->bindValue(":src", $src);
	$summaryinsert->bindValue(":cat", $cat);
	$summaryinsert->bindValue(":last", time());
	$summaryinsert->bindValue(":data", $theResult);
	$qresults = $summaryinsert->execute();
 }
// ok now all the caches should be ready.
$combine = '';

foreach($categories as $category)
{
//	print ("CATEGORY:".$category."<br>");
//	$db->open($database,SQLITE3_OPEN_READWRITE);
	$catmapq->reset();
	$bindRes = $catmapq->bindValue(":cat", $category);
	$mapresults = $catmapq->execute();
//	$db->close();
//	print("RESULT for:".$category." columns:".$results->numColumns()." -- ");
// combine all the call results? or only allow one? 
$remember = array();
// Fetch Associated Array (1 for SQLITE3_ASSOC)
	while ($resArray= $mapresults->fetchArray(1))
	{
 		$src = $resArray['source'];
 		$cat = $resArray['category'];
// 		print("MAP:".$src." ->".$cat."<br>");


 		$summaryq->reset();
 		$bindRes = $summaryq->bindValue(":src", $src);
 		$bindRes = $summaryq->bindValue(":cat", $cat);
 		$qresults = $summaryq->execute();
//	print("summaryq:".$qresults->numColumns()." -- <br>");
	// should only be one result . 
	$qlresults->reset();
	while ($sumr= $qresults->fetchArray(1))
		{
			 $combine.=$sumr['data'];
		}
	}
}

// split into a list
//print "<pre> combine<br>";
print($combine);
//print"</pre>";

  