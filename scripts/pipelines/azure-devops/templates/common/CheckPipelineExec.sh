#!/bin/bash
################################ Description ############################################
# This script is used to get the runId and the result of specific execution of a pipeline
# using the name of the pipeline and the commit on which the pipeline should be executed
################################# Arguments #############################################
# $1 = Name of the pipeline
# $2 = Commit on which the execution you are looking for has been played
################################# Output ################################################
# runId : The Id of the run, you can use it in your pipeline into any task (for example to dowload an artifact from a build pipeline using this Id)
# result : The result of the execution you found, it can be 'canceled', 'failed' or 'succeeded'
################################# Additional infos ######################################
# There is a var called "number_lst", it limits the size of the list of execution,
# feel free to change this value depending on your project
#########################################################################################

# Init var
Pipeline_to_find="$1"
sourceVersion="$2"
i=0
number_lst=100
encontrado="false"

# Getting the id of the pipeline using the name
pipelineInfo=$(az pipelines show --name "$Pipeline_to_find")
id=$(echo "$pipelineInfo" | python -c "import sys, json; print(json.load(sys.stdin)['id'])")
# Getting the list of the last execution (the lenght of the list is defined by the value of $number_lst)
pipelineList=$(az pipelines runs list --pipeline-ids $id --top $number_lst)

# While loop to look at every pipeline execution json one by one
while [[ (("$i" -lt "$number_lst")) ]]
do
  # Getting the commit on which the pipeline has been executed to compare it with the one given as argument
  listSourceVersion=$(echo "$pipelineList" | python -c "import sys, json; print(json.load(sys.stdin)[$i]['sourceVersion'])")
	echo "$listSourceVersion = $sourceVersion"
  if test "$listSourceVersion" = "$sourceVersion"
  then
    # If the commit is the one we are looking for, we get the Id of this execution and the result of it (then stop the while loop)
    encontrado="true"
    result=$(echo "$pipelineList" | python -c "import sys, json; print(json.load(sys.stdin)[$i]['result'])")
    runId=$(echo "$pipelineList" | python -c "import sys, json; print(json.load(sys.stdin)[$i]['id'])")
		break
  fi
  ((i++))
done

echo "runId=$runId  ;  result=$result"
# Those commands are for exporting the value so they can be used in the rest of the pipeline
echo "##vso[task.setvariable variable=runId;]$runId"
echo "##vso[task.setvariable variable=result;]$result"
