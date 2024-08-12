# PostgreSQL Migration Documentation


## Known Limitations
Before proceeding, please review the [known limitations](https://cloud.google.com/database-migration/docs/postgres/known-limitations) of the Database Migration Service (DMS).

# Step 1: Configure Source Instance
- Decide upon a instance to upgrade:

	- We are choosing the rishi-pg14-volcano-staging-pg-a34e9984 instance, a PostgreSQL 14 instance managed via the `galoy-infra/modules/postgresql/gcp` Terraform module.

  ![decide-source](./assets/decide-source-instance.png)

	- The source instance needs to be configured as [follows](https://cloud.google.com/database-migration/docs/postgres/configure-source-database#configure-your-source-instance-postgres)
    
    	- We use a conditional flag in the terraform `galoy-infra/modules/postgresql/gcp` [here](https://github.com/GaloyMoney/galoy-infra/pull/190) 


# Step 2: Create connection profile:
[**Connection Profile Reference**](https://cloud.google.com/database-migration/docs/postgres/create-source-connection-profile)

- A connection profile is configured via the terraform module mentioned above when we enable the `upgradable` flag.

# Step 3: Configure Destination
- Configure New PostgreSQL Instance:
	- **NOTE**: For simplicity keep the **prefix name** of source and destination same. 
	- A terraform module to create a new minimal POSTGRESQL instance can be found in `work/keys/minimal-pg-15` branch of the `galoy-infra` repo [link](https://github.com/GaloyMoney/galoy-infra/tree/work/keys/minimal-pg-15).
    ```sh
    $ git clone https://github.com/GaloyMoney/galoy-infra.git
    $ cd galoy-infra
    $ git switch work/keys/minimal-pg-15
    $ cd postgres-15-barebone
    $ terraform init
    $ terraform apply
    ``` 
	- You can also use create a new instance via the Database migration tool, but I find it a little confusing and complicated.

# Step 4: Start Database Migration Process 

![step-1](./assets/step-1.png)
![step-2](./assets/step-2.png)
![step-3](./assets/step-3.png)
![step-4](./assets/step-4.png)
![step-5](./assets/step-5.png)
![step-6](./assets/step-6.png)
![step-7](./assets/step-7.png)
![step-8](./assets/step-8.png)

### Once you see the **PROMOTE** option in the Database Migration Service, we would need to configure the destination database to be exactly as the source.

# Step 5: Post-promotion Steps

- [Verify Migration Job](https://cloud.google.com/database-migration/docs/postgres/quickstart#verify_the_migration_job) 

> Once you migrated the database using DMS all objects and schema owner will become ‘cloudsqlexternalsync’ by default.

1. Reassign Schema and Object Owners:
     - After migration, all objects and schema owners become cloudsqlexternalsync. Reassign the schema and object owners to match the source instance.
2. Migrate Users and Privileges:
   - Migration does not transfer privileges and users. Create users manually based on the old database.

# Step 5.5: Terraform state sync and user creation

### Step 0
Before altering the state of the source instance we will backup the state so that we can use it later to delete the resources.

```sh
$ cd examples/gcp/
$ mkdir postgres14-source
$ cp -r postgresql/* postgres14-source/
```

### Step 1
Log in to the destination instance as the `postgres` user and change the name of the `cloudsqlexternalsync` user to your source database admin name:

```sql
ALTER USER "cloudsqlexternalsync" RENAME TO "<admin-user-name>";
```

### Step 2
Modify your `main.tf` to reflect the new destination instance by changing the `database_version`:

```hcl
variable "name_prefix" {}
variable "gcp_project" {}
variable "destroyable_postgres" {
  default = true
}

module "postgresql" {
  #source = "git::https://github.com/GaloyMoney/galoy-infra.git//modules/postgresql/gcp?ref=689daa7"
  source = "../../../modules/postgresql/gcp"

  instance_name          = "rishi-pg"
  vpc_name               = "${var.name_prefix}-vpc"
  gcp_project            = var.gcp_project
  destroyable            = var.destroyable_postgres
  user_can_create_db     = true
  databases              = ["test"]
  highly_available       = false
  database_version       = "POSTGRES_15"
  replication            = false
  provision_read_replica = false
  upgradable             = false
  backup                 = false
}
```

### Step 3
Remove the state of the old instance. Below is the list of states to remove when the source instance has only one database named `test`:

```sh
terraform state rm module.postgresql.module.database[\"test\"]
terraform state rm module.postgresql.google_database_migration_service_connection_profile.connection_profile[0]
terraform state rm module.postgresql.random_password.migration[0]
terraform state rm module.postgresql.google_sql_database_instance.instance
terraform state rm $(terraform state list | grep module.postgresql.postgresql_grant)
terraform state rm module.postgresql.postgresql_extension.pglogical[0]
terraform state rm module.postgresql.random_id.db_name_suffix
terraform state rm module.postgresql.google_sql_user.admin
```

Final state:
```sh
terraform state list
module.postgresql.data.google_compute_network.vpc
module.postgresql.random_password.admin
```

### Step 4
Create an `import.tf` file with the following content:

```hcl
import {
  to = module.postgresql.random_id.db_name_suffix
  id = "<b64_url of your db_name_suffix>"
}

import {
  to = module.postgresql.google_sql_database_instance.instance
  id = "projects/volcano-staging/instances/<instance-name>"
}

import {
  to = module.postgresql.module.database["test"].postgresql_database.db
  id = "test"
}
```

> To generate `db_name_suffix`, run:
> ```sh
> echo "<db-suffix>" | xxd -r -p | base64 | tr '/+' '_-' | tr -d '='
> ```

### Step 5 

Finally, do a 

```sh
terraform apply
```
The destination instance should be exactly as with the source PostgreSQL instance.


### Step 6
Now go to the Database Migration Service and once the replication delay is zero, promote the migration.

![promote-migration](./assets/promote-migration.png)
![migration-completed](./assets/migration-completed.png)

The Migration was successful.

![migration-successful](./assets/successful-migration.png)

# Step 7: Delete all the dangling resources
- Delete the Database Migration Service 
- Delete the source instance
  ```sh
  $ cd examples/gcp/postgres14-source
  $ terraform destroy
  $ terraform state rm module.postgresql.google_sql_user.admin 
  $ terraform destroy
  ```
