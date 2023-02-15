         ___        ______     ____ _                 _  ___  
        / \ \      / / ___|   / ___| | ___  _   _  __| |/ _ \ 
       / _ \ \ /\ / /\___ \  | |   | |/ _ \| | | |/ _` | (_) |
      / ___ \ V  V /  ___) | | |___| | (_) | |_| | (_| |\__, |
     /_/   \_\_/\_/  |____/   \____|_|\___/ \__,_|\__,_|  /_/ 
 ----------------------------------------------------------------- 


Hi there! Welcome to AWS Cloud9!

To get started, create some files, play with the terminal,
or visit https://docs.aws.amazon.com/console/cloud9/ for our documentation.

Happy coding!

# NGSL-API-EXTRENAL
Next Generation Service Layer (NGSL) API. This is an EFM external API which EFM clients use to retrieve data
from the Enterprise Data Warehouse (EDW).

## Application structure
The application is an AWS API-Gateway/Lambda function written in Python 3.7+. It uses the following components some of
which are included as stand-alone libraries and some as lambda layers (bundles of stand-alone libraries) as appropriate:
- **Snowflake DB** (Library) - Database driver
- **CyberArk** (Lambda Layer) - Encrypted secrets store for snowflake credentials
- **Lambda Powertools Python** (Library) - A suite of utilities for AWS Lambda functions to ease adopting best practices
such as tracing, structured logging, custom metrics, idempotency, batching, and more.

### Cloud9 Setup
We are using Cloud9 for development, and there are a few things that need to be done in order to be able to access the
given resources like CyberArk & Snowflake.

### AWS Credentials
It is assumed that users have the ***aws-azure-login*** node utility on their local system. Users must run that utility
to generate fresh credentials. The "credentials" file is generated in the <USER_HONME>/.aws directory

### Environment Setup
1. Create a new environment for the project in the Ohio (us-east-2) region, using mostly default settings
2. Specify **CFN-EFM-NonProd-VPC** for the VPC
3. Specify **snowflake-poc-subnetC** for the Subnet
4. After the environment is created, the storage needs to be expanded to allow for the size of the "AWS Toolkit"
   1. Run the "env_utils/resize.sh" script from the project in the terminal window.

### Python Virtual Environment Setup
In order to use a more current version of python (version 3.8) rather than the old default version in cloud9, EC2 instance, we 
will use the **virtualenv** tool. This allows us to create a python virtual environment that matches the python 
version that we specify in our out lambdas template.yaml file.
1. Check if python3.8 is installed, the directory python3.8 should not be listed
```shell
$ ls -l /usr/bin/python3.8
```
2. Install python3.8
```shell
$ sudo amazon-linux-extras install python3.8
```
3. Confirm python3.8 installed; the directory python3.8 should now be listed. The default version of python will still be 
python3.7, but we now have python3.8 available too for use in a virtual environment
```shell
$ ls -l /usr/bin/python3.8
  -rwxr-xr-x 1 root root 7048 Aug 16 20:23 /usr/bin/python3.8
```
4. Confirm virtualenv is installed
```shell
$ virtualenv --version
16.2.0
```
5. Create a python virtual environment using virtualenv for your project with python3.8
```shell
$ virtualenv -p /usr/bin/python3.8 venv
```
5. Activate the new virtual environment.
```shell
$ source venv/bin/activate
(venv) POC-Role:~/environment (master) $
```
6. Check the python version in virtual environment
```shell
(venv) POC-Role:~/environment (master) $ python --version
Python 3.8.5

(venv) POC-Role:~/environment (master) $ python3 --version
Python 3.8.5
```
**NOTE** - you can setup your cloud9 EC2 instance to automatically activate your python virtual environment by 
adding the following lines to the bottom of your <HOME>/.bashrc file. Each time you start cloud9 your terminal will
automatically activate your python virtual environment.
```shell
alias venv="cd ~/environment && source ~/environment/venv/bin/activate"
venv
```
### SQLite3 Update
We use SQLit3 for running our data (unit) tests. SQLite3 is part of the core python3.x distribution so it does 
not need to be listed in the requirements.txt file of the project. However, the cloud9 EC2 instance has a default 
older version (3.7.x) of SQLite3 that overrides anything in a python virtual environment. That [default version 
of SQLite3 does not support "common table expressions" (CTE)](https://stackoverflow.com/questions/18593068/does-sqlite-support-common-table-expressions). We use CTEs in all our snowflake DB queries, so we 
need a version (3.8.3 or greater) of SQLite3 which supports that common feature. For that, you have to update your 
sqlite3 database version manually and then give path of it to your virtual environment.
1. Download the latest sqlite3 from official site. (https://www.sqlite.org/download.html). You will want to download 
the archive with a name like **sqlite-autoconf-3390400.tar.gz**.
2. Extract the compressed archive
```shell
$ tar xvfz sqlite-autoconf-3390400.tar.gz
```
3. Go to that directory and issue the following commands to build and install sqlite3
```shell
$ ./configure
$ make
$ sudo make install
```
4. Finish installing sqlite3 by issueing the following command:
```shell
$ sudo LD_RUN_PATH=/usr/local/lib ./configure --enable-optimizations
```
5. Open your activate file of virtual environment (e.g., venv/bin/activate) and add the following line top of the file.
This will ensure that the new version of sqlite3 will be available to your python virtual environment.
```shell
export LD_LIBRARY_PATH="/usr/local/lib"
```
6. Activate your python virtual environment (if not already) and then confirm the sqlite3 version
```shell
(venv) POC-Role:~/environment (master) $ sqlite3 --version
3.39.4 2022-09-29 15:55:41 a29f9949895322123f7c38fbe94c649a9d6e6c9cd0c3b41c96d694552f26b309
```

### Make File for "making" life easier ;-)
The Makefile was created to help make command line tasks easier/shorter.

### Testing
#### Running Automated (pytest) tests:
    $ python -m pytest tests/unit/

#### Testing SAM events:
    $ make clean
    $ make build
    $ make invoke-customers
    $ make invoke-vehicles

### Troubleshooting
#### Out of Space
Sometimes the EC2 instance will run out of user storage and will need to be cleaned up. This is usually due to logs or 
docker images after excessive usage.
- For cleaning up docker images, please see: [How to clean up aws ec2 server?](https://stackoverflow.com/questions/54814222/how-to-clean-up-aws-ec2-server)

Connect to instance:
    $ sudo -u ec2-user -i
