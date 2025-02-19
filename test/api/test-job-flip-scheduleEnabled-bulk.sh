#!/bin/bash


set -e

# use api V44
API_VERSION=44

DIR=$(cd `dirname $0` && pwd)
source $DIR/include.sh
args="echo hello there"

projectName=""
jobName=""

generate_projectName_and_jobName(){
    projectName="project-$RANDOM"
    jobName="job-$RANDOM"
}

create_job(){
    projname=$1
    jobname=$2
    xmljob=$($XMLSTARLET esc "$jobname")

    #determine h:m:s to run, 10 seconds from now
    NDATES=$(date '+%s')
    NDATES=$(( $NDATES + 10 ))
    osname=$(uname)
    if [ "Darwin" = "$osname" ] ; then
        NDATE=$(date -u -r "$NDATES" '+%Y %m %d %H %M %S')
    else
        NDATE=$(date -u --date="@$NDATES" '+%Y %m %d %H %M %S')
    fi
    NY=$(echo $NDATE | cut -f 1 -d ' ')
    NMO=$(echo $NDATE | cut -f 2 -d ' ')
    ND=$(echo $NDATE | cut -f 3 -d ' ')
    NH=$(echo $NDATE | cut -f 4 -d ' ')
    NM=$(echo $NDATE | cut -f 5 -d ' ')
    NS=$(echo $NDATE | cut -f 6 -d ' ')

    cat > $DIR/job_create.post <<END
<joblist>
   <job>
      <name>$xmljob</name>
      <group>api-test</group>
      <description></description>
      <loglevel>INFO</loglevel>
      <dispatch>
        <threadcount>1</threadcount>
        <keepgoing>true</keepgoing>
      </dispatch>
      <schedule>
        <time hour='$NH' seconds='$NS' minute='$NM' />
        <month month='$NMO'  day='$ND' />
        <year year='$NY' />
      </schedule>
      <sequence>
        <command>
        <exec>echo hello there</exec>
        </command>
      </sequence>
   </job>
</joblist>
END

    jobId=$(uploadJob "$DIR/job_create.post" "$projname"  1 "")
    if [ 0 != $? ] ; then
      errorMsg "failed job upload"
      exit 2
    fi

    echo $jobId
}

create_proj(){
    projname=$1
    jobname=$2

    xmlproj=$($XMLSTARLET esc "$projname")
    xmljob=$($XMLSTARLET esc "$jobname")

    cat > $DIR/proj_create.post <<END
<project>
    <name>$xmlproj</name>
    <description>description for $xmlproj</description>
    <config>
        <property key="test.property" value="test value"/>
    </config>
</project>
END

    runurl="${APIURL}/projects"

    # post (thus creating project)
    docurl -X POST -D $DIR/headers.out --data-binary @$DIR/proj_create.post -H Content-Type:application/xml ${runurl}?${params} > $DIR/curl.out
    if [ 0 != $? ] ; then
        errorMsg "ERROR: failed POST request"
        exit 2
    fi
    rm $DIR/proj_create.post
    assert_http_status 201 $DIR/headers.out

}

delete_proj(){
    projname=$1
    xmlproj=$($XMLSTARLET esc "$projname")

    runurl="${APIURL}/project/$projname"
    docurl -X DELETE  ${runurl} > $DIR/curl.out
    if [ 0 != $? ] ; then
        errorMsg "ERROR: failed DELETE request"
        exit 2
    fi
}


disable_schedule_bulk(){
    jobset=$1

    runurl="${APIURL}/jobs/schedule/disable"
    params="idlist=$jobset"

    docurl -X POST  ${runurl}?${params} > $DIR/curl.out
    if [ 0 != $? ] ; then
        errorMsg "ERROR: failed POST request (disable schedule)"
        exit 2
    fi
    assert_xml_value 'true' '//toggleSchedule/@allsuccessful' $DIR/curl.out
}
enable_schedule_bulk(){
    jobset=$1

    runurl="${APIURL}/jobs/schedule/enable"
    params="idlist=$jobset"

    docurl -X POST  ${runurl}?${params} > $DIR/curl.out
    if [ 0 != $? ] ; then
        errorMsg "ERROR: failed POST request (enable schedule)"
        exit 2
    fi
    assert_xml_value 'true' '//toggleSchedule/@allsuccessful' $DIR/curl.out
}

assert_job_schedule_enabled(){
    jobname=$1
    enabled=$2
    xmljob=$($XMLSTARLET esc "$jobname")

    expectedcount=$2

    runurl="${APIURL}/job/${jobname}"
    params="format=json"

    # get listing
    docurl ${runurl}?${params} > $DIR/curl.out || fail "failed request: ${runurl}"

    assert_json_value $enabled ".[0].scheduleEnabled" $DIR/curl.out
}

####
# Test: when execution is on, job does execute
####

generate_projectName_and_jobName
create_proj $projectName
jobid1=$(create_job $projectName $jobName)
jobid2=$(create_job $projectName "${jobName}-2")

assert_job_schedule_enabled $jobid1 'true'
assert_job_schedule_enabled $jobid2 'true'

# Account for cluster scheduling
sleep 2

echo "TEST: bulk job schedule disable"

disable_schedule_bulk "${jobid1},${jobid2}"

assert_job_schedule_enabled $jobid1 'false'
assert_job_schedule_enabled $jobid2 'false'
echo "OK"

echo "TEST: bulk job schedule enable"
enable_schedule_bulk "${jobid1},${jobid2}"
assert_job_schedule_enabled $jobid1 'true'
assert_job_schedule_enabled $jobid2 'true'
echo "OK"

delete_proj $projectName


exit 0
