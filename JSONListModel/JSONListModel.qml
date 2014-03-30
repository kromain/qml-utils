/* JSONListModel - a QML ListModel with JSON and JSONPath support
*
* Copyright (c) 2012 Romain Pokrzywka (KDAB) (romain@kdab.com)
* Licensed under the MIT licence (http://opensource.org/licenses/mit-license.php)
*/

import QtQuick 2.0
import "jsonpath.js" as JSONPath

Item {
    property string source: ""
    property string contentType: ""
    property string postData: ""
    property string requestType: "GET"
    property string json: ""
    property string query: ""

    property bool loading: false
    property bool listModelUpdate: false

    property ListModel model : ListModel { id: jsonModel }
    property alias count: jsonModel.count

    function refresh() {
        loading = true;
        var xhr = new XMLHttpRequest;
        console.log("Sending request to JSON API")
        console.log("Request Type: "+requestType);
        console.log("Source: "+source);
        xhr.open(requestType, source);
        if (contentType !== "")
            xhr.setRequestHeader("Content-Type", contentType);
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                console.log(xhr.responseText);
                console.log(xhr.getAllResponseHeaders());
                json = xhr.responseText;
                updateJSONModel();
            }
        }
        console.log("Post Data: "+postData)
        if (requestType == "POST") {
            xhr.send(postData);
        } else {
            xhr.send()
        }
    }

    function updateJSONModel() {
        if (jsonModel.count > 0) {
            jsonModel.clear();
        }

        if ( json === "") {
            loading = false;
            return;
        }

        console.log(json);

        var objectArray = parseJSONString(json, query);
        for ( var key in objectArray ) {
            var jo = objectArray[key];
            jsonModel.append(jo);
        }
        loading = false;
        listModelUpdate = !listModelUpdate;
    }

    function parseJSONString(jsonString, jsonPathQuery) {
        var objectArray = JSON.parse(jsonString);
        if ( jsonPathQuery !== "" )
            objectArray = JSONPath.jsonPath(objectArray, jsonPathQuery);

        return objectArray;
    }

    function clear() {
        jsonModel.clear();
    }
}
