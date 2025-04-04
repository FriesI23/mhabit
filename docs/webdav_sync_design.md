<!--
 Copyright 2025 Fries_I23

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

     https://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
-->

# WebDAV Sync Design Overview

The smallest unit for determining differences between the client and server is **Habit**.

- Server to Client:
  - Habit's `etag` changes.
  - Habit doesn't exist on client.
- Client to Server:
  - Habit marked as `dirty`
  - Habit doesn't exist on server.
  - Client’s path configuration has changed.

## Data Design

### Local

| Habit / Designed Field   | Implemented Field         | Desc.                                                                                                        |
| ------------------------ | ------------------------- | ------------------------------------------------------------------------------------------------------------ |
| dirty                    | mh_sync.dirty_total       | Mark if any field of habit or corresponding record changes.                                                  |
| dirty_for_habit          | mh_sync.dirty             | Mark if any field of habit changes                                                                           |
| last_config_uuid         | mh_sync.last_config_uuid  | The UUID of the last server configuration                                                                    |
| last_session_uuid        | mh_sync.last_session_uuid | The UUID of the last sync session                                                                            |
| last_synced_etag         | mh_sync.last_mark_2       | The etag of the last sync represents the version of the data when it was last fetched from the server.       |
| last_synced_session_uuid | mh_sync.last_mark         | The session ID of the last sync where data was fetched from the server and actually written to the local DB. |

| Record / Designed Field  | Implemented Field         | Desc.                                                                                                        |
| ------------------------ | ------------------------- | ------------------------------------------------------------------------------------------------------------ |
| dirty_for_record         | mh_sync.dirty             | Mark if any field of record changes.                                                                         |
| last_config_uuid         | mh_sync.last_config_uuid  | The UUID of the last server configuration.                                                                   |
| last_session_uuid        | mh_sync.last_session_uuid | The UUID of the last sync session.                                                                           |
| last_synced_session_uuid | mh_sync.last_mark         | The session ID of the last sync where data was fetched from the server and actually written to the local DB. |

### Server

| Habit / Designed Field     | Implemented Field               | Desc.                                                                    |
| -------------------------- | ------------------------------- | ------------------------------------------------------------------------ |
| <...Habit Data>            | -                               | see [WebDavSyncHabitData][file.webdav_app_sync_models.dart] for details. |
| last_modified_session_uuid | `WebDavSyncHabitData.sessionId` | The UUID of the session that was last modified from client.              |

| Record / Designed Field    | Implemented Field                | Desc.                                                                     |
| -------------------------- | -------------------------------- | ------------------------------------------------------------------------- |
| <...Record Data>           | -                                | see [WebDavSyncRecordData][file.webdav_app_sync_models.dart] for details. |
| last_modified_session_uuid | `WebDavSyncRecordData.sessionId` | The UUID of the session that was last modified from client.               |

## Flow Design

### Main Task:

```mermaid
flowchart TD
    Start(((Start)))
    End(((End)))

    FetchHabitsMetaFromServer@{ shape: subproc, label: "Fetch Habits Meta (include etag) from Server" }
    QueryHabitsMetaFromLocal@{ shape: subproc, label: "Queryt Habits Meta (include etag, dirty, etc.) from Database" }
    QueryHabitsMetaFromLocal@{ shape: subproc, label: "Queryt Habits Meta (include etag, dirty, etc.) from Database" }

    Start --> FetchHabitsMetaFromServer
    Start --> QueryHabitsMetaFromLocal

    FetchHabitsMetaFromServer --> MergeHabitsMeta
    QueryHabitsMetaFromLocal --> MergeHabitsMeta

    subgraph MergeHabitsMeta [Confirm each habit for download or upload]
        direction LR

        MHM_start@{ shape: docs, label: "For Each Habit"}
        subgraph MHM_HabitMergeResult ["Result"]
            direction LR
            MHM_HabitMergeResult_l(should downdload from server)
            MHM_HabitMergeResult_s(should upload to server)
        end

        MHM_start --> MHM_HabitServer("Habit Meta From Server")
        MHM_HabitServer --> MHM_HabitMergeResult
        MHM_start --> MHM_HabitLocal("Habit Meta From Locale")
        MHM_HabitLocal --> MHM_HabitMergeResult
    end

    MergeHabitsMeta --> HabitSync

    subgraph HabitSync [Separate habit sync process]
        HS_start@{ shape: processes, label: "For Each Habit"}
        HS_Result@{ shape: circle, label: "Sync Result"}

        HS_start --> HS_Server2Local

        subgraph HS_Server2Local ["Server --> Local"]
            direction LR
            HS_S2L_FetchDataFromServer("Fetch Habit data from server")
            HS_S2L_ValidateData("Check Downloaded Data")
            HS_S2L_Write2DB@{shape: tag-rect, label: "Write Habit To Database"}
            HS_S2L_Result@{ shape: circle, label: "Result"}

            HS_S2L_FetchDataFromServer --> HS_S2L_ValidateData
            HS_S2L_ValidateData --> HS_S2L_Write2DB
            HS_S2L_Write2DB --> HS_S2L_Result
        end

        HS_Server2Local --> HS_Local2Server

        subgraph HS_Local2Server ["Local --> Server"]
            direction LR
            HS_L2S_Result((Result))
            HS_L2S_LoadHabitDataFromDB@{shape: tag-rect, label: "Load Habit From DataBase"}
            HS_L2S_UpdateDataToServer(Upload Habit and Records Data to Server)
            HS_L2S_ClearDirtyFlag@{shape: tag-rect, label: "Clear Dirty Flags (from Habit and dependent Records)"}

            HS_L2S_LoadHabitDataFromDB --> HS_L2S_UpdateDataToServer
            HS_L2S_UpdateDataToServer --> HS_L2S_ClearDirtyFlag --> HS_L2S_Result
        end

        HS_Local2Server --> HS_Result
    end

    HabitSync --> CollectionSyncResult
    CollectionSyncResult --> End
```

### Write Habit/Records to DB Task:

```mermaid
flowchart LR
    done(((End)))
    CheckHabitExist{"Check Exist"}

    start(((Start))) --> CheckHabitExist
    CheckHabitExist --> |N| InsertHabit --> done
    CheckHabitExist --> |Y| UpdateHabit --> done

```

#### Insert Habit

```mermaid
flowchart TD
    done(((End)))
    InsertData("Insert Habit Data")
    InsertRecords@{shape: docs, label: "Insert Records Data"}

    start(((Insert))) --> InsertData
    InsertData --> InsertHabitSync

    subgraph InsertHabitSync ["Insert Habit Sync Info"]
        ISHS_dirty("dirty => clear")
        ISHS_dirtyForHabit("dirty_for_habit => clear")
        ISHS_laseSyncSessionId("last_synced_session_uuid => current session's uuid")
        ISHS_etag("etag => current sync's etag")
        ISHS_other("Other: last_config_uuid, last_session_uuid")
    end

    InsertHabitSync --> InsertRecords
    InsertRecords --> InsertRecordsSync

    subgraph InsertRecordsSync ["Insert All Record's Sync Info"]
        ForEachRecord@{ shape: docs, label "For Each Record"}
        ForEachRecord --> ISRS_dirtyForRecord("dirty_for_record => clear")
        ForEachRecord --> ISRS_laseSyncSessionId("last_synced_session_uuid => current session's uuid")
        ForEachRecord --> ISRS_other("Other: last_config_uuid, last_session_uuid")
    end

    InsertRecordsSync --> done
```

#### Update Habit

```mermaid
flowchart TD
    done(((End)))
    start(((Update)))
    CheckEtag{"Check: etag from server == etag from local"}
    CheckIsModified{"Check: Is changed by other session?"}
    CheckSameSessionId{"Check: session id from server == last_session_id"}
    CheckSameSessionId -.-> r1>Some servers don’t return an ETag after a PUT request, so additional checks are needed to prevent unnecessary updates.]
    UpdateData("Update Habit Data")
    UpdateLastSyncSessionId("Update last_synced_session_uuid")
    UpdateOther("Update etag, last_config_uuid, last_session_uuid")

    start --> CheckEtag
    CheckEtag --> | Y - Skipped | UpdateOrInsertRecords
    CheckEtag --> | N | CheckIsModified
    CheckIsModified --> | Y | UpdateOther
    UpdateOther --> UpdateOrInsertRecords
    CheckIsModified --> | N | CheckSameSessionId
    CheckSameSessionId --> | N | UpdateData
    UpdateData --> UpdateM1
    CheckSameSessionId --> | Y | UpdateM1

    subgraph UpdateM1 ["Update Sync Infos"]
        UpdateLastSyncSessionId
        UpdateOther
    end

    UpdateM1 --> UpdateOrInsertRecords

    subgraph UpdateOrInsertRecords ["Insert Or Update All Record's Sync Info"]
        A1((Done))
        ForEachRecord@{ shape: docs, label "For Each Record"}
        CheckRecordExist{"Record is exist?"}
        CheckRecordIsModified{"Check: Record is changed by other session?"}
        CheckRecordIsSameSessionId{Check: Record session id from server == last_session_id}
        CheckRecordIsSameSessionId -.-> rr1>Unlike Habit’s ETag, session id is the only reliable way to determine whether a record has been modified.]
        InsertRecordData("Insert Record Data")
        UpdateRecordData("Update Record Data")

        ForEachRecord --> CheckRecordExist
        CheckRecordExist --> | Y | CheckRecordIsModified
        CheckRecordIsModified --> | N | A1
        CheckRecordIsModified --> | Y | CheckRecordIsSameSessionId
        CheckRecordIsSameSessionId --> | Y | UpdateRecordSync
        CheckRecordIsSameSessionId --> | N | UpdateRecordData
        UpdateRecordData --> UpdateRecordSync

        subgraph UpdateRecordSync ["Update Record Sync Info"]
            U1("Update last_synced_session_uuid")
            U2("Update last_config_uuid, last_session_uuid")
        end

        UpdateRecordSync --> A1
        CheckRecordExist --> | N | InsertRecordData
        InsertRecordData --> InsertRecordSync

        subgraph InsertRecordSync ["Insert Record Sync Info"]
            dirtyForRecord("dirty_for_record => clear")
            laseSyncSessionId("last_synced_session_uuid => current session's uuid")
            other("Other: last_config_uuid, last_session_uuid")
        end

        InsertRecordSync --> A1
    end

    UpdateOrInsertRecords --> done
```

### Load Habit/Records From DB Task:

```mermaid
flowchart TD
    done(((End)))
    start(((Update)))
    ForEachRecord@{ shape: docs, label "For Each Record"}

    start --> LoadHabit
    LoadHabit --> ForEachRecord --> LoadRecord

    subgraph LoadHabit ["Load Habit about Data"]
        LoadHabitResult((Habit Data))
        LoadHabitData("Load Habit Data")
        LoadHabitSyncInfo("Load Habit Sync Info")
        CheckIsModified{"Check Is Modified at Local: is dirty or change config"}

        subgraph A1 [" "]
            LoadHabitData
            LoadHabitSyncInfo
        end

        LoadHabitData --> LoadHabitResult
        LoadHabitSyncInfo --> MergeDirty(Merge dirty_for_habit) --> LoadHabitResult
        LoadHabitSyncInfo --> MergeDirtyTotal(Merge dirty) --> LoadHabitResult
        LoadHabitSyncInfo --> CheckIsModified
        CheckIsModified --> | Y | UpdateHabitDataSesionId{{last_modified_session_uuid => current session id}} --> MergeHabitDataSessionId
        CheckIsModified --> | N | MergeHabitDataSessionId(Merge last_modified_session_uuid)
        MergeHabitDataSessionId --> LoadHabitResult
    end


    subgraph LoadRecord ["Load Record about Data"]
        LoadRecordResult((Record Data))
        LoadRecordData("Load Record Data")
        LoadRecordSyncInfo("Load Record Sync Info")
        CheckRecordIsModified("Check is modified as Local: is dirtyr or change config")

        subgraph A2 [" "]
            LoadRecordData
            LoadRecordSyncInfo
        end

        LoadRecordData --> LoadRecordResult
        LoadRecordSyncInfo --> MergeRecordDirty(Merge dirty_for_record) --> LoadRecordResult
        LoadRecordSyncInfo --> CheckRecordIsModified
        CheckRecordIsModified --> | Y | UpdateRecordDataSessionId{{last_modified_session_uuid => current session id}} --> MergeRecordDataSessionId
        CheckRecordIsModified --> | N | MergeRecordDataSessionId(Merge last_modified_session_uuid)
        MergeRecordDataSessionId --> LoadRecordResult
    end

    LoadRecord --> done
```

### Clear Habit/Records Dirty Flags

```mermaid
flowchart LR
    done(((End)))
    start(((Start)))
    ForEachRecord@{ shape: docs, label "For Each Record"}


    subgraph A1 [" "]
        ClearHabitAbout
        ClearRecordAboud
    end

    subgraph ClearHabitAbout ["For Habit"]
        ClearHabitDirtyFlag("Clear: dirty_for_habit")
        ClearHabitDirtyTotalFlag("Clear: dirty")
        UpdateHabitEtag("Update: etag")
        UpdateHabitEtag -.-> AA1>"If put requst isn't return etag, then update null (Next sync Server2Local processing will sync correct etag)"]
        UpdateHabitOther("Update: last_config_uuid, last_session_uuid")
    end

    subgraph ClearRecordAboud ["For Record"]
        CLearRecordDirtyFlag("Clear: dirty_for_record")
        UpdateRecordOther("Update: last_config_uuid, last_session_uuid")
    end


    start --> ClearHabitAbout --> done
    start --> ForEachRecord --> ClearRecordAboud --> done

```

## Sequence Design

### Single Habit: Server to Local Task

```mermaid
sequenceDiagram
    participant Database
    actor User
    participant Server

    break User Cancelled
        User->>User: Cancel Task
    end
    critical
        User--)+Server: WebDAV GET: habit-xxx.json
        Note over User,Server: use "if-match" header with etag<br/>fetch from PROPFIND request
        Server--)-User: Response
    option Network Error
        User-->>User: Terminal Task with Error
    option Etag Mismatch
        User-->>User: Failed Task
    end
    break User Cancelled
        User->>User: Cancel
    end
    break Response Error
        User->>User: Failed Task
    end
    User->>User: Filter data
    User--)+Database: Write the data to be changed
    Note over User,Database: Use Transaction
    Database--)-User: Data Submitted
```

### Single Habit: Local to Server Task

```mermaid
sequenceDiagram
    participant Database
    actor User
    participant Server

    break User Cancelled
        User->>User: Cancel
    end
    User--)+Database: Load Habit from Database
    Database--)-User: Loaded
    opt is ditry or config id changed
        User->>User: Update modify mark
        Note over User,User: modify make is<br/>"last_synced_session_uuid" at local database<br/>"last_modified_session_uuid" at server json file
    end
    break User Cancelled
        User->>User: Cancel
    end
    critical
        User--)+Server: WebDAV: PUT habit-xxx.json
        Note over User,Server: use "If" header with etag<br/>fetch from PROPFIND request
        Server--)-User: Response
    option Network Error
        User-->>User: Terminal Task with Error
        Note over User,User: Assuming all network errors prevent uploads, <br/>if an upload succeeds but contains errors, <br/>it will be re-uploaded during the next sync <br/>(warn: it may overwrite some previous data).
    option Etag Mismatch
        User-->>User: Failed Task
    end
    par Update last_synced_etag
        alt include "ETag" header within Response Headers
            User--)+Database: Update "last_synced_etag" = <etag>
        else
            User--)Database: Update "last_synced_etag" = null
        end
    and Clear dirty
        alt is Habit
            User--)Database: Clear "dirty_for_habit"
            User--)Database: Clear "dirty"
        else is Record
            User--)Database: Clear "dirty_for_record"
        end
    and Update Other
        User--)Database: Update "last_session_uuid"
        User--)Database: Update "last_config_uuid"
    end
    Database--)-User: Transaction Result
```

<!-- refs -->

[file.webdav_app_sync_models.dart]: ../lib/model/_app_sync_tasks/webdav_app_sync_models.dart
