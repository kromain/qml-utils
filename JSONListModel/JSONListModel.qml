/* JSONListModel - a QML ListModel with JSON and JSONPath support
 *
 * Copyright (c) 2012 Romain Pokrzywka (KDAB) (romain@kdab.com)
 * Licensed under the MIT licence (http://opensource.org/licenses/mit-license.php)
 */

import QtQuick 2.0
import "jsonpath.js" as JSONPath

Item {
    property string source: ""
    property string json: ""
    property string jsonAnt: ""
    property string query: ""
    property string propId: "" // If this property is defined (unique identifier of each object) we'll update only the changes without destroying everything
    
    property ListModel model : ListModel { id: jsonModel }
    property alias count: jsonModel.count
    function get(index){

        return jsonModel.get(index);
    }

    signal jsonModelChanged;

    onSourceChanged: {
        var xhr = new XMLHttpRequest;
        xhr.open("GET", source);
        xhr.onreadystatechange = function() {
            if (xhr.readyState == XMLHttpRequest.DONE)
                json = xhr.responseText;
        }
        xhr.send();
    }

    onJsonChanged: updateJSONModel()
    onQueryChanged: updateJSONModel()

    function updateJSONModel() {
        var objectArray;
        var jo;
        if (json === "")
        {
            jsonModel.clear();
        }
        else if (propId === "" || jsonAnt === "")
        {
            jsonModel.clear();
            objectArray = parseJSONString(json, query);
            for (var key in objectArray ) {
                jo = objectArray[key];
                jsonModel.append(jo);
            }
        }
        else
        {
            console.log("option 3");
            var i, j, id, found;
            objectArray = parseJSONString(json, query);
            var objectArrayAnt = parseJSONString(jsonAnt, query);

            //detecto los insertados y modificados
            for (i = 0; i < objectArray.length; ++i ) {
                id = objectArray[i][propId];
                found = false;
                for (j = 0; j < objectArrayAnt.length; ++j) {
                    if (id === objectArrayAnt[j][propId])
                    {
                        found = true;
                        break;
                    }
                }

                if (!found)
                {
                    console.log("insert " + id);
                    jsonModel.append(objectArray[i]);
                }
                else
                {
                    if (JSON.stringify(objectArray[i]) !== JSON.stringify(objectArrayAnt[j]))
                    {
                        console.log("modified " + id + " index " + j);
                        //jsonModel.set(j, objectArray[i]);
                        jsonModel.remove(j);
                        jsonModel.insert(j, objectArray[i]);
                    }
                }
            }

            //detecto los borrados
            for (i = objectArrayAnt.length - 1; i >= 0; --i ) {
                id = objectArrayAnt[i][propId];
                console.log(id);
                found = false;
                for (j = objectArray.length - 1; j >= 0; --j ) {
                    if (id === objectArray[j][propId])
                    {
                        found = true;
                        break;
                    }
                }
                if (!found)
                {
                    console.log("deleted " + id + " index " + i);
                    jsonModel.remove(i);
                }
            }
        }

        jsonModelChanged();
        jsonAnt = json;
    }

    function parseJSONString(jsonString, jsonPathQuery) {
        var objectArray = JSON.parse(jsonString);
        if ( jsonPathQuery !== "" )
            objectArray = JSONPath.jsonPath(objectArray, jsonPathQuery);

        return objectArray;
    }
}
