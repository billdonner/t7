#  T7- interact with the AI

version  0.3.6, ai = "chatgpt"

replaces Pumper and LieDetector

## AI Mining Process

The AI Mining Process interacts multiple times (and possibly with multiple AIs) to produce a perfect sequence of question blocks for the game Q20K.

### Step 1 - ask the AI to generate question blocks

The Pumper Tempates (system and user) are used to generate an array of JSON blocks about a series of topics from the AI. These blocks are organized by topic and passed to subsequent steps. 

The templates are essentially the system and user panel contents in the OpenAI playground.

The user template can contain multiple sections separated by a line of five stars. Each section is executed as separate request to the AI.

The received blocks are augmented with a generated ID to allow for matching different outputs. 

The augmented blocks are written by default to PUMPER-LOG.JSON

### Step 2 - ask the AI to identify problems in generated data

The Validation Templates (system and user) are used for this phase. The output of this phase is a detailed JSON structure in VALIDATION-LOG.JSON describing the problems in the data; this data will drive utility programs outside this process.

### Step 3 - ask the AI to repair the data

The Repair Templates (system and user) are used for this phase.

For now, we will ignore the output from step 2 on the assumption the ai will itself identify  problems before repairing.

The output file is a stream of repaired JSON blocks in REPAIRED-LOG.JSON 
This file is in precisely the same format as PUMPER-LOG.JSON

### Step 4 - ask the AI to again identify problems in generated data

Hopefully there will be no problems, otherwise we can go back to step 3 or just stop. If going back to step 3 we can rename the REPAIRED-LOG to PUMPER-LOG

## Any Step Can Be Skipped!

It's not always desirable or necessary to run all the steps. Each step can be individually disabled thru the command line.

If Step 1 is skipped an alternative file of previously pumped blocks must be supplied.


## Command Line 
```
OVERVIEW: Chat With AI To Generate Data for Q20K (IOS) App

Step 1 - ask the AI to generate question blocks
Step 2 - ask the AI to identify problems in generated data
Step 3 - ask the AI to repair the data
Step 4 - ask the AI to again identify problems in generated data

USAGE: t7 <pumpsys> <pumpusr> [--valsys <valsys>] [--valusr <valusr>] [--repsys <repsys>] [--repusr <repusr>] [--altpumpurl <altpumpurl>] [--model <model>] [--skipvalidation] [--skiprepair] [--skiprevalidation]

ARGUMENTS:
  <pumpsys>               pumper system template
  <pumpusr>               pumper user template

OPTIONS:
  --valsys <valsys>       validation system template, default is ""
  --valusr <valusr>       validation user template, default is ""
  --repsys <repsys>       repair system template, default is ""
  --repusr <repusr>       repair user template, default is ""
  --altpumpurl <altpumpurl>
                          alternate pumper input file, default is ""
  --model <model>         model (default: gpt-4)
  --skipvalidation        don't run validation step
  --skiprepair            don't run repair step
  --skiprevalidation      don't run re-validation step
  --version               Show the version.
  -h, --help              Show help information.
  ```
