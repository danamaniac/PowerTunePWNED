import QtQuick 2.8
import QtQuick.Controls 2.3
import QtQuick.Controls.Styles 1.4
import QtQuick.Extras 1.4
import QtQuick.Extras.Private 1.0
import QtGraphicalEffects 1.0
import "qrc:/Translator.js" as Translator

Rectangle{
    id: roundGauge
    height : parent.height * (300 / parent.height)//300
    width: height
    color: "transparent"

    property string information: "Round gauge"
    property string mainvaluename
    property double mainvalue:10
    property double maxvalue:100
    property double minvalue:0
    property double warnvaluehigh:100
    property double warnvaluelow
    property double redareastart
    property double divider
    property int needleTipWidth :2
    property int needleLength :100
    property int needleBaseWidth : 30
    property int needleinset
    property int startangle
    property int endangle
    property int tickmarksteps
    property int minortickmarksteps
    property int setlabelsteps
    property int setlabelinset
    property int setminortickmarkinset
    property int setmajortickmarkinset
    property int redareainset :30
    property int redareawidth
    property string tickmarkcolor :"black"
    property string needlecolor: "yellow"
    property string needlecolor2: "red"
    property int decimalpoints: 0
    property string outerneedlecolortrail
    property string middleneedlecortrail
    property string outerneedlecolortrailsave
    property string middleneedlecortrailsave
    property string lowerneedlecolortrailsave
    property string innerneedlecolortrailsave
    property string lowerneedlecolortrail
    property string innerneedlecolortrail
    property string warningcolor: "red"
    property int labelfontsize: 10
    property string labelcoloractive : "white"
    property string labelcolorinactive : "blue"
    property string minortickmarkcoloractive : "white"
    property string minortickmarkcolorinactive : "blue"
    property string majortickmarkcoloractive  : "white"
    property string majortickmarkcolorinactive : "blue"
    property int warningactive
    property int minortickmarkheight:10
    property int minortickmarkwidth:2
    property int tickmarkheight:10
    property int tickmarkwidth
    property string increasedecreaseident
    property string backroundcolor
    property bool needlevisible
    property bool needlecentervisisble
    property bool ringvisible
    property double trailhighboarder :0.5
    property double trailmidboarder  :0.45
    property double traillowboarder  : 0.33
    property double trailbottomboarder : 0.20

    property string labelfont : "Eurostyle"
    property int  desctextx
    property int desctexty
    property int desctextfontsize
    property bool desctextfontbold : true
    property string desctextfonttype : "Eurostyle"
    property string desctextdisplaytext
    property string desctextdisplaytextcolor

    //peak needle

    property string peakneedlecolor
    property string peakneedlecolor2
    property string peakneedlelenght
    property string peakneedlebasewidth
    property string peakneedletipwidth
    property string peakneedleoffset
    property string peakneedlevisible

    Drag.active: true
    DatasourcesList{id: powertunedatasource}

    SequentialAnimation {
        id: intro
        running: true
       onRunningChanged:{
            if (intro.running == false )
                gauge.value  = Qt.binding(function(){return Dashboard[mainvaluename]});
       }
        NumberAnimation {
            id :animation
            target: gauge
            property: "value"
            easing.type: Easing.InOutSine
            from: minvalue
            to: maxvalue
            duration: 1000
        }

        NumberAnimation {
            id :animation1
            target: gauge
            property: "value"
            easing.type: Easing.InBack
            from: maxvalue
            to: minvalue
            duration: 1000
        }
    }
    Connections{
        target: Dashboard
        onDraggableChanged:togglemousearea()
    }


    // MouseArea {
    //     id: touchArea
    //     anchors.fill: parent
    //     drag.target: parent
    //     enabled: false
    //     onDoubleClicked: {
    //         popupmenu.popup(touchArea.mouseX, touchArea.mouseY);
    //     }
    // }

    MouseArea {
        id: touchArea
        anchors.fill: parent
        drag.target: parent
        enabled: false
        onPressed:
        {
            touchCounter++;
            if (touchCounter == 1) {
                lastTouchTime = Date.now();
                timerDoubleClick.restart();
            } else if (touchCounter == 2) {
                var currentTime = Date.now();
                if (currentTime - lastTouchTime <= 500) { // Double-tap detected within 500 ms
                    console.log("Double-tap detected at", mouse.x, mouse.y);
                }
                touchCounter = 0;
                timerDoubleClick.stop();
                popupmenu.popup(touchArea.mouseX, touchArea.mouseY);
            }
        }
        Component.onCompleted: {toggledecimal();
            toggledecimal2();
        }
    }

    Timer {
        id: timerDoubleClick
        interval: 500
        running: false
        repeat: false
        onTriggered: {
            touchCounter = 0; // Reset counter if time interval exceeds 500 ms
        }
    }

    CircularGauge {
        id: gauge
        height: parent.height *0.9
        width : height
        //value: mainvalue
        anchors.centerIn: parent
        maximumValue : maxvalue
        minimumValue: minvalue
        onValueChanged: {
            warn();
        }


        style: CircularGaugeStyle {
            labelStepSize: setlabelsteps
            labelInset: toPixels(setlabelinset*0.01)
            tickmarkStepSize :tickmarksteps
            minorTickmarkCount: minortickmarksteps
            tickmarkInset: setmajortickmarkinset
            minorTickmarkInset: setminortickmarkinset
            minimumValueAngle: startangle
            maximumValueAngle: endangle
            function toPixels(percentage) {
                return percentage * outerRadius;
            }



            needle: Rectangle {
                id:gaugeneedle
                visible: needlevisible
                y: outerRadius * (needleinset * 0.01)
                implicitWidth: outerRadius * (needleBaseWidth *0.01)
                implicitHeight: outerRadius *(needleLength *0.01)
                antialiasing: true
                color: "transparent"
                Canvas {
                    id: needlecanvas
                    anchors.centerIn: parent
                    implicitWidth: parent.width
                    implicitHeight: parent.height
                    property real xCenter: parent.width / 2
                    property real yCenter: parent.height / 2

                    Connections {
                        target: roundGauge
                        onNeedlecolorChanged: needlecanvas.requestPaint()
                        onNeedlecolor2Changed: needlecanvas.requestPaint()
                        onNeedleTipWidthChanged: needlecanvas.requestPaint()
                    }


                    onPaint: {
                        var ctx = getContext("2d");
                        ctx.reset();
                        ctx.beginPath();
                        ctx.moveTo(xCenter, height);
                        ctx.lineTo(xCenter - parent.width / 2, height - parent.width / 2);
                        ctx.lineTo(xCenter - needleTipWidth / 2, 0);
                        ctx.lineTo(xCenter, yCenter - parent.height);
                        ctx.lineTo(xCenter, 0);
                        ctx.closePath();
                        ctx.fillStyle = needlecolor2;
                        ctx.fill();

                        ctx.beginPath();
                        ctx.moveTo(xCenter, height)
                        ctx.lineTo(width, height - parent.width / 2);
                        ctx.lineTo(xCenter + needleTipWidth / 2, 0);
                        ctx.lineTo(xCenter, 0);
                        ctx.closePath();
                        ctx.fillStyle = needlecolor;
                        ctx.fill();
                    }
                }
            }

            foreground: Item {
                id:centerbutton
                visible: needlecentervisisble
                Rectangle {
                    width: outerRadius * 0.2
                    height: width
                    radius: width / 2
                    color: "black"
                    border.color:"grey"
                    anchors.centerIn: parent
                }
            }

            background: Rectangle {
                id: warningbackround
                implicitHeight: gauge.height
                implicitWidth: gauge.width
                color: backroundcolor
                anchors.centerIn: parent
                radius: 360
                Text{id: gaugedescription
                    x:  ((roundGauge.height / 100 ) *desctextx).toFixed(0)
                    y:  ((roundGauge.height / 100 ) *desctexty).toFixed(0)
                    text: desctextdisplaytext
                    color: desctextdisplaytextcolor
                    font.pixelSize: ((roundGauge.height /200) *(desctextfontsize)).toFixed(0)
                    font.family: desctextfonttype
                    font.bold: desctextfontbold
                }
                // Red area

                Canvas {
                    id:redcanvas
                    property int value: redareastart
                    anchors.fill: parent
                    onValueChanged: requestPaint()
                    function degreesToRadians(degrees) {
                        return degrees * (Math.PI / 180);
                    }
                    function toPixels(percentage) {
                        return percentage * outerRadius;
                    }

                    Connections{
                        target: roundGauge
                        onRedareainsetChanged : redcanvas.requestPaint()
                        onRedareawidthChanged : redcanvas.requestPaint()
                    }

                    onPaint: {
                        var ctx = getContext("2d");
                       // var gradient =ctx.createLinearGradient(xStart, yStart, xEnd, yEnd);
                        //var gradient =ctx.createLinearGradient(xStart, yStart, xEnd, yEnd);
                        //var gradient = ctx.createRadialGradient((parent.width / 2),(parent.height / 2), 0, (parent.width / 2),(parent.height / 2),parent.height );
                        //gradient = ctx.createLinearGradient(redareastart, yStart, xEnd, yEnd);
                        //gradient.addColorStop(0.0,"yellow");
                        //gradient.addColorStop(1.0,"red");

                        ctx.reset();
                        ctx.beginPath();
                        ctx.strokeStyle = "red"
                        ctx.lineWidth = toPixels(redareawidth * 0.01)
                        ctx.arc(outerRadius,
                                outerRadius,
                                outerRadius - toPixels(redareainset*0.01) - ctx.lineWidth / 2,
                                degreesToRadians(valueToAngle(redareastart) - 90),
                                degreesToRadians(valueToAngle(gauge.maximumValue) - 90));
                        ctx.stroke();
                    }
                }

                Canvas {
                    id: needletrail
                    property int value: gauge.value

                    anchors.fill: parent
                    onValueChanged: requestPaint()

                    function degreesToRadians(degrees) {
                        return degrees * (Math.PI / 180);

                    }

                    onPaint: {
                       // console.log(gauge.value)
                        var ctx = getContext("2d");
                        var gradient2;
                        gradient2 = ctx.createRadialGradient((parent.width / 2),(parent.height / 2), 0, (parent.width / 2),(parent.height / 2),parent.height );
                        gradient2.addColorStop(trailhighboarder, outerneedlecolortrail);   //outer needle ring color
                        gradient2.addColorStop(trailmidboarder, middleneedlecortrail);   //middle needle ring color
                        gradient2.addColorStop(traillowboarder, lowerneedlecolortrail);   //lower needle ring color
                        gradient2.addColorStop(trailbottomboarder, "transparent");   //lower needle ring color


                        ctx.reset();
                        ctx.beginPath();
                        ctx.strokeStyle = gradient2
                        ctx.lineWidth = outerRadius
                        ctx.arc(outerRadius,
                                outerRadius,
                                outerRadius - ctx.lineWidth / 2,
                                degreesToRadians(valueToAngle(gauge.minimumValue) - 90),
                                degreesToRadians(valueToAngle(gauge.value) - 90));
                        ctx.stroke();
                    }
                }
            }

            tickmarkLabel:  Text {
                id:labeltext
                font.pixelSize: toPixels(labelfontsize*0.01) //Math.max(6, outerRadius * 0.05)
                text: styleData.value / divider
                font.bold: true
                font.family: labelfont
                color: styleData.value <= gauge.value ? labelcoloractive : labelcolorinactive
                antialiasing: true
            }

            minorTickmark: Rectangle {
                implicitWidth: toPixels(minortickmarkwidth *0.01)
                implicitHeight: toPixels(minortickmarkheight *0.01)
                antialiasing: true
                smooth: true
                color: styleData.value <= gauge.value ? minortickmarkcoloractive : minortickmarkcolorinactive

            }

            tickmark:  Rectangle {
                implicitWidth: toPixels(tickmarkwidth *0.01)
                implicitHeight: toPixels(tickmarkheight *0.01)
                antialiasing: true
                smooth: true
                color: styleData.value <= gauge.value ? majortickmarkcoloractive : majortickmarkcolorinactive
            }
        }
    }
    Image {
        id: ring
        anchors.fill: parent
        visible: ringvisible
        source: "qrc:/graphics/RoungGaugeRing.png"
    }
    Item {
        id: menustructure

        Menu{
            id: popupmenu
            font.pixelSize: 15
            z:1000
            MenuItem {
                text: Translator.translate("Test sweep", Dashboard.language)
                font.pixelSize: 15
                onClicked: intro.running = true;
            }


            MenuItem {
                text: Translator.translate("Datasource", Dashboard.language)
                font.pixelSize: 15
                onClicked: {datasourcemenue.popup(touchArea.mouseX, touchArea.mouseY);//gaugesizesmenue.visible= true;
                }
            }
            MenuItem {
                text: Translator.translate("Size and ring", Dashboard.language)
                font.pixelSize: 15
                onClicked: {gaugesizesmenue.popup(touchArea.mouseX, touchArea.mouseY);//gaugesizesmenue.visible= true;
                         for(var i = 0; i < backroundcolorselect.model.count; ++i) if (backroundcolorselect.textAt(i) === backroundcolor)backroundcolorselect.currentIndex = i ;
                }
            }
            MenuItem {
                text: Translator.translate("Start Stop values", Dashboard.language)
                font.pixelSize: 15
                onClicked: startstopmenu.popup(touchArea.mouseX, touchArea.mouseY);
            }
            MenuItem {
                text: Translator.translate("Needle", Dashboard.language)
                font.pixelSize: 15
                onClicked: {needlemenu.popup(touchArea.mouseX, touchArea.mouseY);
                    for(var i = 0; i < needlecolor2select.model.count; ++i) if (needlecolor2select.textAt(i) === needlecolor2)needlecolor2select.currentIndex = i;
                    for(var a = 0; a < needlecolorselect.model.count; ++a) if (needlecolorselect.textAt(a) === needlecolor)needlecolorselect.currentIndex = a ;

                }
            }
            MenuItem {
                text: Translator.translate("Needle trail", Dashboard.language)
                font.pixelSize: 15
                onClicked: {needletrailmenu.popup(touchArea.mouseX, touchArea.mouseY);
                for(var a = 0; a < lowerneedlecolortrailselect.model.count; ++a) if (lowerneedlecolortrailselect.textAt(a) === lowerneedlecolortrailsave)lowerneedlecolortrailselect.currentIndex = a ;
                for(var b = 0; b < middleneedlecortrailcolorselect.model.count; ++b) if (middleneedlecortrailcolorselect.textAt(b) === middleneedlecortrailsave)middleneedlecortrailcolorselect.currentIndex = b ;
                for(var c = 0; c < outerneedlecolortrailcolorselect.model.count; ++c) if (outerneedlecolortrailcolorselect.textAt(c) === outerneedlecolortrailsave)outerneedlecolortrailcolorselect.currentIndex = c;
}

            }
            MenuItem {
                text: Translator.translate("Minor ticks", Dashboard.language)
                font.pixelSize: 15
                onClicked: {minortickmarkmenu.popup(touchArea.mouseX, touchArea.mouseY);
                    for(var a = 0; a < minortickmarkcolorainctiveselect.model.count; ++a) if (minortickmarkcolorainctiveselect.textAt(a) === minortickmarkcolorinactive)minortickmarkcolorainctiveselect.currentIndex = a;
                    for(var i = 0; i < minortickmarkcoloractiveselect.model.count; ++i) if (minortickmarkcoloractiveselect.textAt(i) === minortickmarkcoloractive)minortickmarkcoloractiveselect.currentIndex = i;
                }

            }
            MenuItem {
                text: Translator.translate("Major ticks", Dashboard.language)
                font.pixelSize: 15
                onClicked: {majortickmarkmenu.popup(touchArea.mouseX, touchArea.mouseY);//gaugesizesmenue.visible= true;
                    for(var i = 0; i < tickmarkcolorinactiveselect.model.count; ++i) if (tickmarkcolorinactiveselect.textAt(i) === majortickmarkcolorinactive)tickmarkcolorinactiveselect.currentIndex = i;
                    for(var a = 0; a < tickmarkcoloractiveselect.model.count; ++a) if (tickmarkcoloractiveselect.textAt(a) === majortickmarkcoloractive)tickmarkcoloractiveselect.currentIndex = a ;
                }

            }
            MenuItem {
                text: Translator.translate("Labels", Dashboard.language)
                font.pixelSize: 15
                onClicked: {labelsandticks.popup(touchArea.mouseX, touchArea.mouseY);
                    for(var a = 0; a < labelfontselect.model.count; ++a) if (labelfontselect.textAt(a) === labelfont)labelfontselect.currentIndex = a ;
                    for(var b = 0; b < labelcolor1select.model.count; ++b) if (labelcolor1select.textAt(b) === labelcoloractive)labelcolor1select.currentIndex = b ;
                    for(var c = 0; c < labelcolor2select.model.count; ++c) if (labelcolor2select.textAt(c) === labelcolorinactive)labelcolor2select.currentIndex = c ;

                }
            }
            MenuItem {
                text: Translator.translate("Warnings", Dashboard.language)
                font.pixelSize: 15
                onClicked: warningmenu.popup(touchArea.mouseX, touchArea.mouseY);
            }
            MenuItem {
                text: Translator.translate("Description text", Dashboard.language)
                font.pixelSize: 15
                onClicked: {descriptionmenu.popup(touchArea.mouseX, touchArea.mouseY);
                    for(var i = 0; i < desclabelfontselect.model.count; ++i) if (desclabelfontselect.textAt(i) === desclabelfont)desclabelfontselect.currentIndex = i ;
                    for(var j = 0; j < desctextdisplaytextcolorselect.model.count; ++j) if (desctextdisplaytextcolorselect.textAt(j) === desctextdisplaytextcolor)desctextdisplaytextcolorselect.currentIndex = j ;
                }
            }
            MenuItem {
                text: Translator.translate("Delete gauge", Dashboard.language)
                font.pixelSize: 15
                onClicked: roundGauge.destroy();
            }
            ////////////////////////////
            /*
            MenuItem {
                text: "Colors"
                font.pixelSize: 15
                onClicked: {colorselector.visible = true;
                            touchArea.enabled = false;
                }
            }
            MenuItem {
                text: "Needle visible"
                font.pixelSize: 15
                onClicked: {toggleneedle()}
            }
           */
        }
    }
Rectangle{
    id: submenue
    Drag.active: true
    MouseArea {
        anchors.fill: parent
        drag.target: parent
        enabled: false
    }
    Menu{
        id : datasourcemenue
        closePolicy :Popup.NoAutoClose
        Rectangle {
            color: "darkgrey"
            width:popupmenu.width
            height: 100
            radius: 10
            Grid {
                id :datasourcemenuegrid
                rows: 2
                columns: 1
                rowSpacing :5
                leftPadding: 5
        ComboBox {
            id: cbxDatasource
            width:popupmenu.width
            visible: true
            textRole: "titlename"
            model: powertunedatasource
            //powertunedatasource.get(cbxMain.currentIndex).sourcename;
            Component.onCompleted: {for(var i = 0; i < cbxDatasource.model.count; ++i) if (powertunedatasource.get(i).sourcename === mainvaluename)cbxDatasource.currentIndex = i}

        }
        RoundButton{
            text: Translator.translate("Close menu", Dashboard.language)
            font.bold: true
            font.pixelSize : 15
            width: parent.width /1.07
            onClicked: {
                mainvaluename = powertunedatasource.get(cbxDatasource.currentIndex).sourcename;
                datasourcemenue.close();
                touchArea.enabled = true;}
        }
    }
    }
    }

    Menu{
        id : gaugesizesmenue
        closePolicy :Popup.NoAutoClose
    Rectangle {
        color: "darkgrey"
        width:popupmenu.width
        height: 340
        radius: 10
        Grid {
            id :gaugesizesmenuegrid
            rows: 15
            columns: 1
            rowSpacing :5
            leftPadding: 5
            Text {
                text: Translator.translate("Gauge size", Dashboard.language)
                font.bold: true
                font.pixelSize: 15
                horizontalAlignment: Text.AlignHCenter

            }
            Grid {
                rows: 1
                columns: 3
                rowSpacing :5
                RoundButton{text: "-"
                    width: popupmenu.width /3.2

                    onPressAndHold: {timer.running = true;
                        increasedecreaseident = "decreasegaugesize"}
                    onReleased: {timer.running = false;}
                    onClicked: {roundGauge.width--;
                        roundGauge.height--;}
                }
                Text{text: roundGauge.width
                    width: popupmenu.width /3.2

                    horizontalAlignment: Text.AlignHCenter
                }
                RoundButton{ text: "+"
                    width: popupmenu.width /3.2

                    onPressAndHold: {timer.running = true;
                        increasedecreaseident = "increasegaugesize"}
                    onReleased: {timer.running = false;}
                    onClicked: {roundGauge.width++;
                        roundGauge.height++;}
                }
            }

            Text {
                text: Translator.translate("Background color", Dashboard.language)
                font.bold: true
                font.pixelSize: 15}

            ComboBox {
                id: backroundcolorselect
                width: popupmenu.width /1.07
                model: ColorList{}
                visible: true
                font.pixelSize: 15
                currentIndex: 1
                onCurrentIndexChanged: {backroundcolor = backroundcolorselect.textAt(backroundcolorselect.currentIndex)}
                delegate:
                    ItemDelegate {
                    width: backroundcolorselect.width
                    font.pixelSize: 15
                    Rectangle {
                        width: backroundcolorselect.width
                        height: 50
                        color:  itemColor
                        Text {
                            text: itemColor
                            anchors.centerIn: parent
                            font.pixelSize: 15
                        }
                    }
                }
                background:Rectangle{
                    width: backroundcolorselect.width
                    height: backroundcolorselect.height
                    color:  backroundcolorselect.currentText
                }
            }

            RoundButton{
                text: Translator.translate("Needle visible", Dashboard.language)
                font.bold: true
                font.pixelSize : 15
                width: parent.width /1.07
                onClicked: toggleneedle()
            }
            RoundButton{
                text: Translator.translate("Needle button visible", Dashboard.language)
                font.bold: true
                font.pixelSize : 15
                width: parent.width /1.07
                onClicked: toggleneedlecenter()
            }
            RoundButton{
                text: Translator.translate("Outer ring visible", Dashboard.language)
                font.bold: true
                font.pixelSize : 15
                width: parent.width /1.07
                onClicked: togglering()
            }
            RoundButton{
                text: Translator.translate("Close menu", Dashboard.language)
                font.bold: true
                font.pixelSize : 15
                width: parent.width /1.07
                onClicked: {gaugesizesmenue.close();
                    touchArea.enabled = true;}
            }
        }
    }
}

    Menu{
        id : startstopmenu
        closePolicy :Popup.NoAutoClose
    Rectangle{
        color: "darkgrey"
        width:popupmenu.width
        radius: 10
        height: 365
        Column {
            anchors.fill: parent
            spacing: 10
            leftPadding: 5
            Text {
                text: Translator.translate("Start value", Dashboard.language)
                font.bold: true
                font.pixelSize: 15}
            Grid {
                rows: 1
                columns: 3
                rowSpacing :5
                RoundButton{text: "-"
                    width: popupmenu.width /3.2
                    onPressAndHold: {timer.running = true;
                        increasedecreaseident = "decreaseminvalue"}
                    onReleased: {timer.running = false;}
                    onClicked: {minvalue--}
                }
                TextField{
                    id : minvaluetext
                    text: minvalue
                    onTextChanged: minvalue = minvaluetext.text
                    width: popupmenu.width /3.2
                    horizontalAlignment: Text.AlignHCenter
                    inputMethodHints :Qt.ImhFormattedNumbersOnly
                }
                RoundButton{ text: "+"
                    width: popupmenu.width /3.2

                    onPressAndHold: {timer.running = true;
                        increasedecreaseident = "increaseminvalue"}
                    onReleased: {timer.running = false;}
                    onClicked: {minvalue++}
                }
            }

            Text {
                text: Translator.translate("End value", Dashboard.language)
                font.bold: true
                font.pixelSize: 15}
            Grid {
                rows: 1
                columns: 3
                rowSpacing :5
                RoundButton{text: "-"

                    width: popupmenu.width /3.2
                    onPressAndHold: {timer.running = true;
                        increasedecreaseident = "decreasemaxvalue"}
                    onReleased: {timer.running = false;}
                    onClicked: {maxvalue--}
                }
                TextField{
                    id: maxText
                    text: maxvalue
                    width: popupmenu.width /3.2
                    horizontalAlignment: Text.AlignHCenter
                    onTextChanged: maxvalue = maxText.text
                    font.pixelSize: 15
                }
                RoundButton{ text: "+"
                    width: popupmenu.width /3.2

                    onPressAndHold: {timer.running = true;
                        increasedecreaseident = "increasemaxvalue"}
                    onReleased: {timer.running = false;}
                    onClicked: {maxvalue++}
                }
            }
            Text {
                text: Translator.translate("Start angle", Dashboard.language)
                font.pixelSize: 15
                font.bold : true
            }

            Grid {
                rows: 1
                columns: 3
                rowSpacing :5
                RoundButton{text: "-"
                    width: popupmenu.width /3.2
                    onPressAndHold: {timer.running = true;
                        increasedecreaseident = "decreasestartangle"}
                    onReleased: {timer.running = false;}
                    onClicked: {startangle--;}
                }
                TextField{text: startangle
                    width: popupmenu.width /3.2
                    horizontalAlignment: Text.AlignHCenter
                }
                RoundButton{ text: "+"
                    width: popupmenu.width /3.2
                    onPressAndHold: {timer.running = true;
                        increasedecreaseident = "increasestartangle"}
                    onReleased: {timer.running = false;}
                    onClicked: {startangle++;}
                }
            }

            Text {
                text: Translator.translate("End angle", Dashboard.language)
                font.pixelSize: 15
                font.bold :true
            }
            Grid {
                rows: 1
                columns: 3
                rowSpacing :5
                RoundButton{text: "-"
                    width: popupmenu.width /3.2
                    onPressAndHold: {timer.running = true;
                        increasedecreaseident = "decreaseendangle"}
                    onReleased: {timer.running = false;}
                    onClicked: {endangle--;}
                }
                TextField{text: endangle
                    width: popupmenu.width /3.2
                    horizontalAlignment: Text.AlignHCenter
                }
                RoundButton{ text: "+"
                    width: popupmenu.width /3.2
                    onPressAndHold: {timer.running = true;
                        increasedecreaseident = "increaseendangle"}
                    onReleased: {timer.running = false;}
                    onClicked: {endangle++;}
                }
            }
            RoundButton{
                text: Translator.translate("Close menu", Dashboard.language)
                font.bold: true
                font.pixelSize : 15
                width: parent.width /1.07
                onClicked: {startstopmenu.visible = false;
                    touchArea.enabled = true;}
            }
        }
    }
}
    /////////////////////////////////////////////}
    Menu{
        id : needlemenu
        closePolicy :Popup.NoAutoClose
    Rectangle{
        color: "darkgrey"
        width:popupmenu.width
        height: 460
        radius: 10

        Grid {
            rows: 25
            leftPadding: 5
            rowSpacing :5

            Text {
                text: Translator.translate("Needle color", Dashboard.language)
                font.bold: true
                font.pixelSize: 15}
            ComboBox {
                id: needlecolorselect
                width: popupmenu.width /1.07
                model: ColorList{}
                visible: true
                font.pixelSize: 15
                currentIndex: 1
                onCurrentIndexChanged: {needlecolor = needlecolorselect.textAt(needlecolorselect.currentIndex)}
                delegate:
                    ItemDelegate {
                    width: needlecolorselect.width
                    font.pixelSize: 15
                    Rectangle {
                        width: needlecolorselect.width
                        height: 50
                        color:  itemColor
                        Text {
                            text: itemColor
                            anchors.centerIn: parent
                            font.pixelSize: 15
                        }
                    }
                }
                background:Rectangle{
                    width: needlecolorselect.width
                    height: needlecolorselect.height
                    color:  needlecolorselect.currentText
                }
            }
            ComboBox {
                id: needlecolor2select
                width: popupmenu.width /1.07
                model: ColorList{}
                visible: true
                font.pixelSize: 15
                currentIndex: 1
                onCurrentIndexChanged: {needlecolor2 = needlecolor2select.textAt(needlecolor2select.currentIndex)}
                delegate:
                    ItemDelegate {
                    width: needlecolor2select.width
                    font.pixelSize: 15
                    Rectangle {
                        width: needlecolor2select.width
                        height: 50
                        color:  itemColor
                        Text {
                            text: itemColor
                            anchors.centerIn: parent
                            font.pixelSize: 15
                        }
                    }
                }
                background:Rectangle{
                    width: needlecolor2select.width
                    height: needlecolor2select.height
                    color:  needlecolor2select.currentText
                }
            }

            Text {
                text: Translator.translate("Needle lenght", Dashboard.language)
                font.bold: true
                font.pixelSize: 15}
            Grid {
                rows: 1
                columns: 3
                rowSpacing :5
                RoundButton{text: "-"
                    width: popupmenu.width /3.2
                    onPressAndHold: {timer.running = true;
                        increasedecreaseident = "decreaseneedleLength"}
                    onReleased: {timer.running = false;}
                    onClicked: {needleLength--;}
                }
                TextField{text: needleLength
                    width: popupmenu.width /3.2
                    horizontalAlignment: Text.AlignHCenter
                }
                RoundButton{ text: "+"
                    width: popupmenu.width /3.2
                    onPressAndHold: {timer.running = true;
                        increasedecreaseident = "increaseneedleLength"}
                    onReleased: {timer.running = false;}
                    onClicked: {needleLength++;}
                }
            }
            Text {
                text: Translator.translate("Needle base width", Dashboard.language)
                font.bold: true
                font.pixelSize: 15}
            Grid {
                rows: 1
                columns: 3
                rowSpacing :5
                RoundButton{text: "-"
                    width: popupmenu.width /3.2
                    onPressAndHold: {timer.running = true;
                        increasedecreaseident = "decreaseneedleBaseWidth"}
                    onReleased: {timer.running = false;}
                    onClicked: {needleBaseWidth--;}
                }
                TextField{text: needleBaseWidth
                    width: popupmenu.width /3.2
                    horizontalAlignment: Text.AlignHCenter

                }
                RoundButton{ text: "+"
                    width: popupmenu.width /3.2
                    onPressAndHold: {timer.running = true;
                        increasedecreaseident = "increaseneedleBaseWidth"}
                    onReleased: {timer.running = false;}
                    onClicked: {needleBaseWidth++;}
                }
            }
            Text {
                text: Translator.translate("Needle tip width", Dashboard.language)
                font.bold: true
                font.pixelSize: 15}
            Grid {
                rows: 1
                columns: 3
                rowSpacing :5
                RoundButton{text: "-"
                    width: popupmenu.width /3.2
                    onPressAndHold: {timer.running = true;
                        increasedecreaseident = "decreaseneedleTipWidth"}
                    onReleased: {timer.running = false;}
                    onClicked: {needleTipWidth--;}
                }
                TextField{text: needleTipWidth
                    width: popupmenu.width /3.2
                    horizontalAlignment: Text.AlignHCenter

                }
                RoundButton{ text: "+"
                    width: popupmenu.width /3.2
                    onPressAndHold: {timer.running = true;
                        increasedecreaseident = "increaseneedleTipWidth"}
                    onReleased: {timer.running = false;}
                    onClicked: {needleTipWidth++;}
                }
            }

            Text {
                text: Translator.translate("Needle offset", Dashboard.language)
                font.bold: true
                font.pixelSize: 15}
            Grid {
                rows: 1
                columns: 3
                rowSpacing :5
                RoundButton{text: "-"
                    width: popupmenu.width /3.2
                    onPressAndHold: {timer.running = true;
                        increasedecreaseident = "decreaseneedleinset"}
                    onReleased: {timer.running = false;}
                    onClicked: {needleinset--;}
                }
                TextField{text: needleinset
                    width: popupmenu.width /3.2
                    horizontalAlignment: Text.AlignHCenter

                }
                RoundButton{ text: "+"
                    width: popupmenu.width /3.2
                    onPressAndHold: {timer.running = true;
                        increasedecreaseident = "increaseneedleinset"}
                    onReleased: {timer.running = false;}
                    onClicked: {needleinset++;}
                }
            }
            RoundButton{
                text: Translator.translate("Close menu", Dashboard.language)
                font.bold: true
                font.pixelSize : 15
                width: parent.width /1.07
                onClicked: {needlemenu.visible = false;
                    touchArea.enabled = true;}
            }
        }
    }
}
    //////////////////
    Menu{
        id: needletrailmenu
        closePolicy :Popup.NoAutoClose
    Rectangle{
        color: "darkgrey"
        width:popupmenu.width
        height: 260
        radius: 10
        Grid {
            rows: 12
            leftPadding: 5
            rowSpacing :5
            Text {
                text: Translator.translate("Outer needle trail", Dashboard.language)
                font.bold: true
                font.pixelSize: 15
            }
            ComboBox {
                id: outerneedlecolortrailcolorselect
                width: popupmenu.width /1.07
                model: ColorList{}
                visible: true
                font.pixelSize: 15
                currentIndex: 1
                onCurrentIndexChanged: {outerneedlecolortrail = outerneedlecolortrailcolorselect.textAt(outerneedlecolortrailcolorselect.currentIndex)
                    outerneedlecolortrailsave = outerneedlecolortrail;
                }
                delegate:
                    ItemDelegate {
                    id:itemDelegate
                    width: outerneedlecolortrailcolorselect.width
                    font.pixelSize: 15
                    Rectangle {
                        width: outerneedlecolortrailcolorselect.width
                        height: 50
                        color:  itemColor
                        Text {
                            text: itemColor
                            anchors.centerIn: parent
                            font.pixelSize: 15
                        }
                    }
                }

                background:Rectangle{
                    width: outerneedlecolortrailcolorselect.width
                    height: outerneedlecolortrailcolorselect.height
                    color:  outerneedlecolortrailcolorselect.currentText
                }
            }

            Text {
                text: Translator.translate("Middle needle trail", Dashboard.language)
                font.bold: true
                font.pixelSize: 15

            }
            ComboBox {
                id: middleneedlecortrailcolorselect
                width: popupmenu.width /1.07
                model: ColorList{}
                visible: true
                font.pixelSize: 15
                currentIndex: 1
                onCurrentIndexChanged: {middleneedlecortrail = middleneedlecortrailcolorselect.textAt(middleneedlecortrailcolorselect.currentIndex)
                    middleneedlecortrailsave = middleneedlecortrail;}
                delegate:
                    ItemDelegate {
                    width: middleneedlecortrailcolorselect.width
                    font.pixelSize: 15
                    Rectangle {
                        width: middleneedlecortrailcolorselect.width
                        height: 50
                        color:  itemColor
                        Text {
                            text: itemColor
                            anchors.centerIn: parent
                            font.pixelSize: 15
                        }
                    }
                }
                background:Rectangle{
                    width: middleneedlecortrailcolorselect.width
                    height: middleneedlecortrailcolorselect.height
                    color:  middleneedlecortrailcolorselect.currentText
                }
            }
            Text {
                text: Translator.translate("Lower needle trail", Dashboard.language)
                font.bold: true
                font.pixelSize: 15
                horizontalAlignment: Text.AlignHCenter
            }
            ComboBox {
                id: lowerneedlecolortrailselect
                width: popupmenu.width / 1.07
                model: ColorList{}
                visible: true
                font.pixelSize: 15
                currentIndex: 1
                onCurrentIndexChanged: {lowerneedlecolortrail = lowerneedlecolortrailselect.textAt(lowerneedlecolortrailselect.currentIndex)
                    lowerneedlecolortrailsave = lowerneedlecolortrail;}
                delegate:
                    ItemDelegate {
                    width: lowerneedlecolortrailselect.width
                    font.pixelSize: 15
                    Rectangle {
                        width: lowerneedlecolortrailselect.width
                        height: 50
                        color:  itemColor
                        Text {
                            text: itemColor
                            anchors.centerIn: parent
                            font.pixelSize: 15
                        }
                    }
                }
                background:Rectangle{
                    width: lowerneedlecolortrailselect.width
                    height: lowerneedlecolortrailselect.height
                    color:  lowerneedlecolortrailselect.currentText
                }
            }
            RoundButton{
                text: Translator.translate("Close menu", Dashboard.language)
                font.bold: true
                font.pixelSize : 15
                width: parent.width /1.07
                onClicked: {needletrailmenu.visible = false;
                    touchArea.enabled = true;}
            }
        }
    }
}

    Menu{
        id : minortickmarkmenu
        closePolicy :Popup.NoAutoClose
    Rectangle {
        color: "darkgrey"
        width:popupmenu.width
        height: 440
        Grid {
            rows: 15
            rowSpacing :5
            leftPadding: 5
            Text {
                text: Translator.translate("Minor tickmark height", Dashboard.language)
                font.bold: true
                font.pixelSize: 15}
            Grid {
                rows: 1
                columns: 3
                rowSpacing :5
                RoundButton{text: "-"
                    width: popupmenu.width /3.2
                    onPressAndHold: {timer.running = true;
                        increasedecreaseident = "decreaseminortickmarkheight"}
                    onReleased: {timer.running = false;}
                    onClicked: {minortickmarkheight--}
                }
                Text{text: minortickmarkheight
                    width: popupmenu.width /3.2
                    horizontalAlignment: Text.AlignHCenter
                }
                RoundButton{ text: "+"

                    width: popupmenu.width /3.2
                    onPressAndHold: {timer.running = true;
                        increasedecreaseident = "increaseminortickmarkheight"}
                    onReleased: {timer.running = false;}
                    onClicked: {minortickmarkheight++}
                }
            }
            Text {
                text: Translator.translate("Minor tickmark width", Dashboard.language)
                font.bold: true
                font.pixelSize: 15}
            Grid {
                rows: 1
                columns: 3
                rowSpacing :5
                RoundButton{text: "-"
                    width: popupmenu.width /3.2
                    onPressAndHold: {timer.running = true;
                        increasedecreaseident = "decreaseminortickmarkwidth"}
                    onReleased: {timer.running = false;}
                    onClicked: {minortickmarkwidth--}
                }
                Text{text: minortickmarkwidth
                    horizontalAlignment: Text.AlignHCenter
                    width: popupmenu.width /3.2}
                RoundButton{ text: "+"

                    width: popupmenu.width /3.2
                    onPressAndHold: {timer.running = true;
                        increasedecreaseident = "increaseminortickmarkwidth"}
                    onReleased: {timer.running = false;}
                    onClicked: {minortickmarkwidth++}
                }
            }
            Text {
                text: Translator.translate("Minor tickmark steps", Dashboard.language)
                font.bold: true
                font.pixelSize: 15}
            Grid {
                rows: 1
                columns: 3
                rowSpacing :5
                RoundButton{text: "-"

                    width: popupmenu.width /3.2
                    onPressAndHold: {timer.running = true;
                        increasedecreaseident = "decreaseminortickmarksteps"}
                    onReleased: {timer.running = false;}
                    onClicked: {minortickmarksteps--}
                }
                Text{text: minortickmarksteps
                    horizontalAlignment: Text.AlignHCenter
                    width: popupmenu.width /3.2}
                RoundButton{ text: "+"

                    width: popupmenu.width /3.2
                    onPressAndHold: {timer.running = true;
                        increasedecreaseident = "increaseminortickmarksteps"}
                    onReleased: {timer.running = false;}
                    onClicked: {minortickmarksteps++}
                }
            }

            Text {
                text: Translator.translate("Minor tickmark inset", Dashboard.language)
                font.bold: true
                font.pixelSize: 15}
            Grid {
                rows: 1
                columns: 3
                rowSpacing :5
                RoundButton{text: "-"
                    width: popupmenu.width /3.2
                    onPressAndHold: {timer.running = true;
                        increasedecreaseident = "decreasesetminortickmarkinset"}
                    onReleased: {timer.running = false;}
                    onClicked: {setminortickmarkinset--}
                }
                Text{text: setminortickmarkinset
                    horizontalAlignment: Text.AlignHCenter
                    width: popupmenu.width /3.2}
                RoundButton{ text: "+"
                    width: popupmenu.width /3.2
                    onPressAndHold: {timer.running = true;
                        increasedecreaseident = "increasesetminortickmarkinset"}
                    onReleased: {timer.running = false;}
                    onClicked: {setminortickmarkinset++}
                }
            }
            Text {
                text:Translator.translate("Minor tick active color", Dashboard.language)
                font.pixelSize: 15
                font.bold: true
            }
            ComboBox {
                id: minortickmarkcoloractiveselect
                width: popupmenu.width /1.07
                model: ColorList{}
                visible: true
                font.pixelSize: 15
                currentIndex: 1
                onCurrentIndexChanged: {minortickmarkcoloractive = minortickmarkcoloractiveselect.textAt(minortickmarkcoloractiveselect.currentIndex)}
                delegate:
                    ItemDelegate {
                    width: minortickmarkcoloractiveselect.width
                    font.pixelSize: 15
                    Rectangle {
                        width: minortickmarkcoloractiveselect.width
                        height: 50
                        color:  itemColor
                        Text {
                            text: itemColor
                            anchors.centerIn: parent
                            font.pixelSize: 15
                        }
                    }
                }
                background:Rectangle{
                    width: minortickmarkcoloractiveselect.width
                    height: minortickmarkcoloractiveselect.height
                    color:  minortickmarkcoloractiveselect.currentText
                }
            }
            Text {
                text: Translator.translate("Minor tick inactive color", Dashboard.language)
                font.pixelSize: 15
                font.bold: true
            }
            ComboBox {
                id: minortickmarkcolorainctiveselect
                width: popupmenu.width /1.07
                model: ColorList{}
                visible: true
                font.pixelSize: 15
                currentIndex: 1
                onCurrentIndexChanged: {minortickmarkcolorinactive = minortickmarkcolorainctiveselect.textAt(minortickmarkcolorainctiveselect.currentIndex)}
                delegate:
                    ItemDelegate {
                    width: minortickmarkcolorainctiveselect.width
                    font.pixelSize: 15
                    Rectangle {
                        width: minortickmarkcolorainctiveselect.width
                        height: 50
                        color:  itemColor
                        Text {
                            text: itemColor
                            anchors.centerIn: parent
                            font.pixelSize: 15
                        }
                    }
                }
                background:Rectangle{
                    width: minortickmarkcolorainctiveselect.width
                    height: minortickmarkcolorainctiveselect.height
                    color:  minortickmarkcolorainctiveselect.currentText
                }
            }
            RoundButton{
                text: Translator.translate("Close menu", Dashboard.language)
                font.bold: true
                font.pixelSize : 15
                width: popupmenu.width /1.07
                onClicked: {minortickmarkmenu.visible = false;
                    touchArea.enabled = true;}
            }
        }
    }
}
    //////////////////////////////////////////////////////////////
    Menu{
        id: majortickmarkmenu
        closePolicy :Popup.NoAutoClose
    Rectangle{
        color: "darkgrey"
        width:popupmenu.width
        height: 480
        Grid {
            rows: 7
            rowSpacing :5
            leftPadding: 5

            Grid {
                rows: 12
                rowSpacing :5

                Text {
                    text: Translator.translate("Major tick steps", Dashboard.language)
                    font.bold: true
                    font.pixelSize: 15
                }
                Grid {
                    rows: 12
                    rowSpacing :5

                    Grid {
                        rows: 1
                        columns: 3
                        rowSpacing :5
                        RoundButton{text: "-"
                            width: popupmenu.width /3.2
                            onPressAndHold: {timer.running = true;
                                increasedecreaseident = "decreasetickmarksteps"}
                            onReleased: {timer.running = false;}
                            onClicked: {ticksteps.text--;
                                tickmarksteps = ticksteps.text*divider;
                            }
                        }
                        TextField{
                            id: ticksteps
                            text: tickmarksteps / divider
                            width: popupmenu.width /3.2
                            horizontalAlignment: Text.AlignHCenter
                            onTextChanged: tickmarksteps = ticksteps.text*divider;
                        }
                        RoundButton{ text: "+"
                            width: popupmenu.width /3.2
                            onPressAndHold: {timer.running = true;
                                increasedecreaseident = "increasetickmarksteps"}
                            onReleased: {timer.running = false;}
                            onClicked: {ticksteps.text++;
                                tickmarksteps = ticksteps.text*divider;}
                        }
                    }

                    Text {
                        text: Translator.translate("Major tickmark height", Dashboard.language)
                        font.bold: true
                        font.pixelSize: 15}
                    Grid {
                        rows: 1
                        columns: 3
                        rowSpacing :5
                        RoundButton{text: "-"
                            width: popupmenu.width /3.2

                            onPressAndHold: {timer.running = true;
                                increasedecreaseident = "decreasetickmarkheight"}
                            onReleased: {timer.running = false;}
                            onClicked: {tickmarkheight--}
                        }
                        Text{text: tickmarkheight

                            width: popupmenu.width /3.2
                            horizontalAlignment: Text.AlignHCenter
                        }
                        RoundButton{ text: "+"

                            width: popupmenu.width /3.2
                            onPressAndHold: {timer.running = true;
                                increasedecreaseident = "increasetickmarkheight"}
                            onReleased: {timer.running = false;}
                            onClicked: {tickmarkheight++}
                        }
                    }
                    Text {
                        text: Translator.translate("Major tickmark width", Dashboard.language)
                        font.bold: true
                        font.pixelSize: 15
                    }
                    Grid {
                        rows: 1
                        columns: 3
                        rowSpacing :5
                        RoundButton{text: "-"

                            width: popupmenu.width /3.2
                            onPressAndHold: {timer.running = true;
                                increasedecreaseident = "decreasetickmarkwidth"}
                            onReleased: {timer.running = false;}
                            onClicked: {tickmarkwidth--}
                        }
                        Text{text: tickmarkwidth

                            width: popupmenu.width /3.2
                            horizontalAlignment: Text.AlignHCenter
                        }
                        RoundButton{ text: "+"

                            width: popupmenu.width /3.2
                            onPressAndHold: {timer.running = true;
                                increasedecreaseident = "increasetickmarkwidth"}
                            onReleased: {timer.running = false;}
                            onClicked: {tickmarkwidth++}
                        }
                    }
                    Text {
                        text: Translator.translate("Major tickmark inset", Dashboard.language)
                        font.bold: true
                        font.pixelSize: 15
                    }
                    Grid {
                        rows: 1
                        columns: 3
                        rowSpacing :5
                        RoundButton{text: "-"

                            width: popupmenu.width /3.2
                            onPressAndHold: {timer.running = true;
                                increasedecreaseident = "decreasesetmajortickmarkinset"}
                            onReleased: {timer.running = false;}
                            onClicked: {setmajortickmarkinset--}
                        }
                        Text{text: setmajortickmarkinset

                            width: popupmenu.width /3.2
                            horizontalAlignment: Text.AlignHCenter
                        }
                        RoundButton{ text: "+"

                            width: popupmenu.width /3.2
                            onPressAndHold: {timer.running = true;
                                increasedecreaseident = "increasesetmajortickmarkinset"}
                            onReleased: {timer.running = false;}
                            onClicked: {setmajortickmarkinset++}
                        }
                    }

                    Text {
                        text: Translator.translate("Tickmark active color", Dashboard.language)
                        font.pixelSize: 15
                        font.bold: true
                    }
                    ComboBox {
                        id: tickmarkcoloractiveselect
                        width: popupmenu.width /1.07
                        model: ColorList{}
                        visible: true
                        font.pixelSize: 15
                        currentIndex: 1
                        onCurrentIndexChanged: {majortickmarkcoloractive = tickmarkcoloractiveselect.textAt(tickmarkcoloractiveselect.currentIndex)}
                        delegate:
                            ItemDelegate {
                            width: tickmarkcoloractiveselect.width
                            font.pixelSize: 15
                            Rectangle {
                                width: tickmarkcoloractiveselect.width
                                height: 50
                                color:  itemColor
                                Text {
                                    text: itemColor
                                    anchors.centerIn: parent
                                    font.pixelSize: 15
                                }
                            }
                        }
                        background:Rectangle{
                            width: tickmarkcoloractiveselect.width
                            height: tickmarkcoloractiveselect.height
                            color:  tickmarkcoloractiveselect.currentText
                        }
                    }
                    Text {
                        text: Translator.translate("Tickmark inactive color", Dashboard.language)
                        font.pixelSize: 15
                        font.bold: true
                    }
                    ComboBox {
                        id: tickmarkcolorinactiveselect
                        width: popupmenu.width /1.07
                        model: ColorList{}
                        visible: true
                        font.pixelSize: 15
                        currentIndex: 1
                        onCurrentIndexChanged: {majortickmarkcolorinactive = tickmarkcolorinactiveselect.textAt(tickmarkcolorinactiveselect.currentIndex)}
                        delegate:
                            ItemDelegate {
                            width: tickmarkcolorinactiveselect.width
                            font.pixelSize: 15
                            Rectangle {
                                width: tickmarkcolorinactiveselect.width
                                height: 50
                                color:  itemColor
                                Text {
                                    text: itemColor
                                    anchors.centerIn: parent
                                    font.pixelSize: 15
                                }
                            }
                        }
                        background:Rectangle{
                            width: tickmarkcolorinactiveselect.width
                            height: tickmarkcolorinactiveselect.height
                            color:  tickmarkcolorinactiveselect.currentText
                        }
                    }
                    RoundButton{
                        text: Translator.translate("Close menu", Dashboard.language)
                        font.bold: true
                        font.pixelSize : 15
                        width: parent.width /1.07
                        onClicked: {majortickmarkmenu.visible = false;
                            touchArea.enabled = true;}
                    }
                }

            }
        }
    }
}
Menu{
    id: labelsandticks
    closePolicy :Popup.NoAutoClose
Rectangle{
        color: "darkgrey"
        width:popupmenu.width
        height: 440

        Grid {
            rows: 20
            rowSpacing :5
            Text {
                text: Translator.translate("Major label steps", Dashboard.language)
                font.bold: true
                font.pixelSize: 15
            }
            Grid {
                rows: 1
                columns: 3
                rowSpacing :5
                RoundButton{text: "-"
                    width: popupmenu.width /3.2
                    onPressAndHold: {timer.running = true;
                        increasedecreaseident = "decreasesetlabelsteps"}
                    onReleased: {timer.running = false;}
                    onClicked: {labelsteps.text--;
                        setlabelsteps = labelsteps.text*divider;
                    }
                }
                TextField{
                    id: labelsteps
                    text: setlabelsteps / divider
                    width: popupmenu.width /3.2
                    horizontalAlignment: Text.AlignHCenter
                }
                RoundButton{ text: "+"
                    width: popupmenu.width /3.2
                    onPressAndHold: {timer.running = true;
                        increasedecreaseident = "increasesetlabelsteps"}
                    onReleased: {timer.running = false;}
                    onClicked: {labelsteps.text++;
                        setlabelsteps = labelsteps.text*divider;
                    }
                }
            }
            Text {
                text: Translator.translate("Label size", Dashboard.language)
                font.bold: true
                font.pixelSize: 15}
            Grid {
                rows: 1
                columns: 3
                rowSpacing :5
                leftPadding: 5
                RoundButton{text: "-"

                    width: popupmenu.width /3.2
                    onPressAndHold: {timer.running = true;
                        increasedecreaseident = "decreaselabelfontsize"}
                    onReleased: {timer.running = false;}
                    onClicked: {labelfontsize--}
                }
                Text{text: labelfontsize

                    width: popupmenu.width /3.2
                    horizontalAlignment: Text.AlignHCenter
                }
                RoundButton{ text: "+"
                    width: popupmenu.width /3.2

                    onPressAndHold: {timer.running = true;
                        increasedecreaseident = "increaselabelfontsize"}
                    onReleased: {timer.running = false;}
                    onClicked: {labelfontsize++}
                }
            }
            Text {
                text: Translator.translate("Label inset", Dashboard.language)
                font.pixelSize: 15
                font.bold: true
            }
            Grid {
                rows: 1
                columns: 3
                rowSpacing :5
                RoundButton{text: "-"
                    width: popupmenu.width /3.2
                    onPressAndHold: {timer.running = true;
                        increasedecreaseident = "decreasesetlabelinset"}
                    onReleased: {timer.running = false;}
                    onClicked: {setlabelinset--}
                }
                Text{text: setlabelinset
                    width: popupmenu.width /3.2
                    horizontalAlignment: Text.AlignHCenter
                }
                RoundButton{ text: "+"
                    width: popupmenu.width /3.2
                    onPressAndHold: {timer.running = true;
                        increasedecreaseident = "increasesetlabelinset"}
                    onReleased: {timer.running = false;}
                    onClicked: {setlabelinset++}
                }
            }
            ////Qt.fontFamilies()
            Text {
                text: Translator.translate("Label Font", Dashboard.language)
                font.pixelSize: 15
                font.bold: true
            }
            ComboBox{
                id: labelfontselect
                width: popupmenu.width
                model: Qt.fontFamilies()
                visible:true
                font.pixelSize: 15
                currentIndex: 1
                onCurrentIndexChanged: {labelfont = labelfontselect.textAt(labelfontselect.currentIndex)
                //console.log("font changed")
                }
                delegate:
                    ItemDelegate {
                    text: modelData
                    width: labelfontselect.width
                    font.pixelSize: 15
                    font.family: modelData
                }
            }

            Text {
                text: Translator.translate("Label active color", Dashboard.language)
                font.pixelSize: 15
                font.bold: true
            }
            ComboBox {
                id: labelcolor1select
                width: popupmenu.width
                model: ColorList{}
                visible: true
                font.pixelSize: 15
                currentIndex: 1
                onCurrentIndexChanged: {labelcoloractive = labelcolor1select.textAt(labelcolor1select.currentIndex)}
                delegate:
                    ItemDelegate {
                    width: labelcolor1select.width
                    font.pixelSize: 15
                    Rectangle {
                        width: labelcolor1select.width
                        height: 50
                        color:  itemColor
                        Text {
                            text: itemColor
                            anchors.centerIn: parent
                            font.pixelSize: 15
                        }
                    }
                }
                background:Rectangle{
                    width: labelcolor1select.width
                    height: labelcolor1select.height
                    color:  labelcolor1select.currentText
                }
            }
            Text {
                text: Translator.translate("Label inactive color", Dashboard.language)
                font.pixelSize: 15
                font.bold: true
            }
            ComboBox {
                id: labelcolor2select
                width: popupmenu.width
                model: ColorList{}
                visible: true
                font.pixelSize: 15
                currentIndex: 1
                onCurrentIndexChanged: {labelcolorinactive = labelcolor2select.textAt(labelcolor2select.currentIndex)}
                delegate:
                    ItemDelegate {
                    width: labelcolor2select.width
                    font.pixelSize: 15
                    Rectangle {
                        width: labelcolor2select.width
                        height: 50
                        color:  itemColor
                        Text {
                            text: itemColor
                            anchors.centerIn: parent
                            font.pixelSize: 15
                        }
                    }
                }
                background:Rectangle{
                    width: labelcolor2select.width
                    height: labelcolor2select.height
                    color:  labelcolor2select.currentText
                }
            }
            RoundButton{
                text: Translator.translate("Close menu", Dashboard.language)
                font.bold: true
                font.pixelSize: 15
                width: parent.width /1.07
                onClicked: {labelsandticks.visible = false
                    touchArea.enabled = true;
                }
            }
        }
    }
}

    /////////////////////////////////////////
Menu{
    id : warningmenu
    closePolicy :Popup.NoAutoClose
    Rectangle {
        color: "darkgrey"
        width:popupmenu.width
        radius: 10
        height: 400
        Grid {
            rows: 12
            rowSpacing :5
            leftPadding: 5
            Text {
                text: Translator.translate("Low warning trigger", Dashboard.language)
                font.pixelSize: 15
                font.bold: true
            }
            Grid {
                rows: 1
                columns: 3
                rowSpacing :5
                RoundButton{text: "-"
                    width: popupmenu.width /3.2
                    onPressAndHold: {timer.running = true;
                        increasedecreaseident = "decreasewarnvaluelow"}
                    onReleased: {timer.running = false;}
                    onClicked: {warnvaluelow--}
                }
                Text{text: warnvaluelow
                    width: popupmenu.width /3.2
                    horizontalAlignment: Text.AlignHCenter
                }
                RoundButton{ text: "+"
                    width: popupmenu.width /3.2
                    onPressAndHold: {timer.running = true;
                        increasedecreaseident = "increasewarnvaluelow"}
                    onReleased: {timer.running = false;}
                    onClicked: {warnvaluelow++}
                }
            }
            Text {
                text: Translator.translate("High warning trigger", Dashboard.language)
                font.pixelSize: 15
                font.bold: true
            }
            Grid {
                rows: 1
                columns: 3
                rowSpacing :5
                RoundButton{text: "-"
                    width: popupmenu.width /3.2
                    onPressAndHold: {timer.running = true;
                        increasedecreaseident = "decreasewarnvaluehigh"}
                    onReleased: {timer.running = false;}
                    onClicked: {warnvaluehigh--}
                }
                TextField{id: warnvaluehightxt
                    text: warnvaluehigh
                    width: popupmenu.width /3.2
                    horizontalAlignment: Text.AlignHCenter
                    onTextChanged: warnvaluehigh = warnvaluehightxt.text
                }
                RoundButton{ text: "+"
                    width: popupmenu.width /3.2
                    onPressAndHold: {timer.running = true;
                        increasedecreaseident = "increasewarnvaluehigh"}
                    onReleased: {timer.running = false;}
                    onClicked: {warnvaluehigh++}
                }
            }
            Text {
                text: Translator.translate("Red area inset", Dashboard.language)
                font.pixelSize: 15
                font.bold: true
            }
            Grid {
                rows: 1
                columns: 3
                rowSpacing :5
                RoundButton{text: "-"
                    width: popupmenu.width /3.2
                    onPressAndHold: {timer.running = true;
                        increasedecreaseident = "decreaseredareainset"}
                    onReleased: {timer.running = false;}
                    onClicked: {redareainset--}
                }
                 TextInput{id: redareainsettxt
                    text: redareainset
                    width: popupmenu.width /3.2
                    validator :IntValidator {bottom: 0;top:100}
                    horizontalAlignment: Text.AlignHCenter
                    onTextChanged: redareainset = redareainsettxt.text
                }
                RoundButton{ text: "+"
                    width: popupmenu.width /3.2
                    onPressAndHold: {timer.running = true;
                        increasedecreaseident = "increaseredareainset"}
                    onReleased: {timer.running = false;}
                    onClicked: {redareainset++}
                }
            }
            Text {
                text: Translator.translate("Red start", Dashboard.language)
                font.pixelSize: 15
                font.bold: true
            }
            Grid {
                rows: 1
                columns: 3
                rowSpacing :5
                RoundButton{text: "-"
                    width: popupmenu.width /3.2
                    onPressAndHold: {timer.running = true;
                        increasedecreaseident = "decreasereredareastart"}
                    onReleased: {timer.running = false;}
                    onClicked: {redareastart --}
                }
                TextField{id: redareastarttxt
                    text: redareastart
                    width: popupmenu.width /3.2
                    horizontalAlignment: Text.AlignHCenter
                    onTextChanged: redareastart = redareastarttxt.text
                }
                RoundButton{ text: "+"
                    width: popupmenu.width /3.2
                    onPressAndHold: {timer.running = true;
                        increasedecreaseident = "increasereredareastart"}
                    onReleased: {timer.running = false;}
                    onClicked: {redareastart++}
                }
            }

            Text {
                text: Translator.translate("Red area width", Dashboard.language)
                font.pixelSize: 15
                font.bold: true
            }
            Grid {
                rows: 1
                columns: 3
                rowSpacing :5
                RoundButton{text: "-"
                    width: popupmenu.width /3.2
                    onPressAndHold: {timer.running = true;
                        increasedecreaseident = "decreaseredareawidth"}
                    onReleased: {timer.running = false;}
                    onClicked: {redareawidth--}
                }
                TextField{id: redareawidthttxt
                    text: redareawidth
                    width: popupmenu.width /3.2
                    horizontalAlignment: Text.AlignHCenter
                    onTextChanged: redareawidth = redareawidthttxt.text
                }
                RoundButton{ text: "+"
                    width: popupmenu.width /3.2
                    onPressAndHold: {timer.running = true;
                        increasedecreaseident = "increaseredareawidth"}
                    onReleased: {timer.running = false;}
                    onClicked: {redareawidth++}
                }
            }

            RoundButton{
                text: Translator.translate("Close menu", Dashboard.language)
                font.bold: true
                font.pixelSize: 15
                width: parent.width /1.07
                onClicked: {warningmenu.visible = false;
                    touchArea.enabled = true;
                }
            }
        }
    }
}
Menu{
    id :descriptionmenu
    closePolicy :Popup.NoAutoClose
    Rectangle {
        color: "darkgrey"
        width:popupmenu.width
        radius: 10
        height: 440
        Grid {
            rows: 13
            rowSpacing :5
            leftPadding: 5
            Text {
                text: Translator.translate("Horizontal position", Dashboard.language)
                font.pixelSize: 15
                font.bold: true
            }
            Grid {
                rows: 1
                columns: 3
                rowSpacing :5
                RoundButton{text: "-"
                    width: popupmenu.width /3.2
                    onPressAndHold: {timer.running = true;
                        increasedecreaseident = "decreasedesctextx";}
                    onReleased: {timer.running = false;}
                    onClicked: { desctextx--}
                }
                TextField{id: desctextxtext
                    text: desctextx
                    width: popupmenu.width /3.2
                    horizontalAlignment: Text.AlignHCenter
                    onTextChanged: desctextx = desctextxtext.text
                }
                RoundButton{ text: "+"
                    width: popupmenu.width /3.2
                    onPressAndHold: {timer.running = true;
                        increasedecreaseident = "increasedesctextx";}
                    onReleased: {timer.running = false;}
                    onClicked: { desctextx++}
                }
            }

            Text {
                text: Translator.translate("Vertical position", Dashboard.language)
                font.pixelSize: 15
                font.bold: true
            }

            Grid {
                rows: 1
                columns: 3
                rowSpacing :5
                RoundButton{text: "-"
                    width: popupmenu.width /3.2
                    onPressAndHold: {timer.running = true;
                        increasedecreaseident = "decreasedesctexty";}
                    onReleased: {timer.running = false;}
                    onClicked: { desctexty--}
                }
                TextField{id: desctextytext
                    text: desctexty
                    width: popupmenu.width /3.2
                    horizontalAlignment: Text.AlignHCenter
                    onTextChanged: desctexty = desctextytext.text
                }
                RoundButton{ text: "+"
                    width: popupmenu.width /3.2
                    onPressAndHold: {timer.running = true;
                        increasedecreaseident = "increasedesctexty";}
                    onReleased: {timer.running = false;}
                    onClicked: { desctexty++}
                }
            }
            //////////////
            Text {
                text: Translator.translate("Fontsize", Dashboard.language)
                font.pixelSize: 15
                font.bold: true
            }
            Grid {
                rows: 1
                columns: 3
                rowSpacing :5
                RoundButton{text: "-"
                    width: popupmenu.width /3.2
                    onPressAndHold: {timer.running = true;
                        increasedecreaseident = "decreasedesctextfontsize";}
                    onReleased: {timer.running = false;}
                    onClicked: { desctextfontsize--}
                }
                TextField{id: desctextfontsizetext
                    text: desctextfontsize
                    width: popupmenu.width /3.2
                    horizontalAlignment: Text.AlignHCenter
                    onTextChanged: desctextfontsize = desctextfontsizetext.text
                }
                RoundButton{ text: "+"
                    width: popupmenu.width /3.2
                    onPressAndHold: {timer.running = true;
                        increasedecreaseident = "increasedesctextfontsize";}
                    onReleased: {timer.running = false;}
                    onClicked: { desctextfontsize++}
                }
            }

            Text {
                text: Translator.translate("Font", Dashboard.language)
                font.pixelSize: 15
                font.bold: true
            }
            ComboBox{
                id: desclabelfontselect
                width: popupmenu.width
                model: Qt.fontFamilies()
                visible:true
                font.pixelSize: 15
                currentIndex: 1
                onCurrentIndexChanged: {desctextfonttype = desclabelfontselect.textAt(desclabelfontselect.currentIndex)}
                delegate:
                    ItemDelegate {
                    text: modelData
                    width: desclabelfontselect.width
                    font.pixelSize: 15
                    font.family: modelData
                }
            }
            Text {
                text: Translator.translate("Font color", Dashboard.language)
                font.pixelSize: 15
                font.bold: true
            }
            ComboBox {
                id: desctextdisplaytextcolorselect
                width: popupmenu.width
                model: ColorList{}
                visible: true
                font.pixelSize: 15
                currentIndex: 1 
                onCurrentIndexChanged: {desctextdisplaytextcolor = desctextdisplaytextcolorselect.textAt(desctextdisplaytextcolorselect.currentIndex)}
                delegate:
                    ItemDelegate {
                    width: desctextdisplaytextcolorselect.width
                    font.pixelSize: 15
                    Rectangle {
                        width: desctextdisplaytextcolorselect.width
                        height: 50
                        color:  itemColor
                        Text {
                            text: itemColor
                            anchors.centerIn: parent
                            font.pixelSize: 15
                        }
                    }
                }
                background:Rectangle{
                    width: desctextdisplaytextcolorselect.width
                    height: desctextdisplaytextcolorselect.height
                    color:  desctextdisplaytextcolorselect.currentText
                }
            }
            Text {
                text: Translator.translate("Display Text", Dashboard.language)
                font.pixelSize: 15
                font.bold: true
            }
            TextField{
                id : desctextdisplaytexttext
                text: desctextdisplaytext
                onTextChanged: desctextdisplaytext = desctextdisplaytexttext.text
                width: popupmenu.width
                horizontalAlignment: Text.AlignHCenter
            }


            RoundButton{
                text: Translator.translate("Close menu", Dashboard.language)
                font.bold: true
                font.pixelSize: 15
                width: parent.width /1.07
                onClicked: {descriptionmenu.visible = false;
                    touchArea.enabled = true;
                }
            }
        ////////////////
            /*
    property bool desctextfontbold
              */
        }
    }
}
}
    ///////////////////////////////////
    Item {
        Timer {
            id: timer
            interval: 50; running: false; repeat: true
            onTriggered: {increaseDecrease()}
        }

        Text { id: time }
    }
    //Functions


    function togglemousearea()
    {
        if (Dashboard.draggable === 1)
        {
            touchArea.enabled = true;
        }
        else
            touchArea.enabled = false;
    }
    //Gauge Test
    function animateGauge()
    {

    }
    function increaseDecrease()
    {
       // console.log("ident "+ increasedecreaseident);
        switch(increasedecreaseident)
        {

        case "increasegaugesize": {
            roundGauge.width++;
            roundGauge.height++;
            break;
        }
        case "decreasegaugesize": {
            roundGauge.width--;
            roundGauge.height--;
            break;
        }
        case "increaselabelfontsize": {
            labelfontsize++;
            break;
        }
        case "decreaselabelfontsize": {
            labelfontsize--;
            break;
        }
        case "increasesetlabelinset": {
            setlabelinset++;
            break;
        }
        case "decreasesetlabelinset": {
            setlabelinset--;
            break;
        }
        case "decreasestartangle": {
            startangle--;
            break;
        }
        case "increasestartangle": {
            startangle++;
            break;
        }
        case "decreaseendangle": {
            endangle--;
            break;
        }
        case "increaseendangle": {
            endangle++;
            break;
        }
        case "decreasesetlabelsteps": {
            labelsteps.text--;
            setlabelsteps = labelsteps.text*divider;
            tickmarksteps = labelsteps.text*divider;
            break;
        }
        case "increasesetlabelsteps": {
            labelsteps.text++;
            setlabelsteps = labelsteps.text*divider;
            tickmarksteps = labelsteps.text*divider;
            break;
        }
        case "increaseendangle": {
            endangle++;
            break;
        }
        case "decreaseminortickmarkheight": {
            minortickmarkheight--;
            break;
        }
        case "increaseminortickmarkheight": {
            minortickmarkheight++;
            break;
        }
        case "decreaseminortickmarkwidth": {
            minortickmarkwidth--;
            break;
        }
        case "increaseminortickmarkwidth": {
            minortickmarkwidth++;
            break;
        }
        case "decreasetickmarkheight": {
            tickmarkheight--;
            break;
        }
        case "increasetickmarkheight": {
            tickmarkheight++;
            break;
        }
        case "decreasetickmarkwidth": {
            tickmarkwidth--;
            break;
        }
        case "increasetickmarkwidth": {
            tickmarkwidth++;
            break;
        }
        case "decreaseminortickmarksteps": {
            minortickmarksteps--;
            break;
        }
        case "increaseminortickmarksteps": {
            minortickmarksteps++;
            break;
        }
        case "decreasesetminortickmarkinset": {
            setminortickmarkinset--;
            break;
        }
        case "increasesetminortickmarkinset": {
            setminortickmarkinset++;
            break;
        }
        case "decreasetickmarksteps": {
            ticksteps.text--;
            break;
        }
        case "increasetickmarksteps": {
            ticksteps.text++;
            break;
        }
        case "decreaseneedleinset": {
            needleinset--;
            break;
        }
        case "increaseneedleinset": {
            needleinset++;
            break;
        }
        case "decreaseminvalue": {
            minvalue--;
            break;
        }
        case "increaseminvalue": {
            minvalue++;
            break;
        }
        case "decreasemaxvalue": {
            maxvalue--;
            break;
        }
        case "increasemaxvalue": {
            maxvalue++;
            break;
        }
        case "decreaseneedleLength": {
            needleLength--;
            break;
        }
        case "increaseneedleLength": {
            needleLength++;
            break;
        }

        case "decreaseneedleBaseWidth": {
            needleBaseWidth--;
            break;
        }
        case "increaseneedleBaseWidth": {
            needleBaseWidth++;
            break;
        }
        case "decreaseneedleTipWidth": {
            needleTipWidth--;
            break;
        }
        case "increaseneedleTipWidth": {
            needleTipWidth++;
            break;
        }
        case "decreaseneedleinset": {
            needleinset--;
            break;
        }
        case "increaseneedleinset": {
            needleinset++;
            break;
        }
        case "decreasesetmajortickmarkinset": {
            setmajortickmarkinset--;
            break;
        }
        case "increasesetmajortickmarkinset": {
            setmajortickmarkinset++;
            break;
        }
        }
    }
    function toggleneedle()
    {
        if (needlevisible === true){needlevisible = false}
        else needlevisible = true;

    }
    function toggleneedlecenter()
    {
        if (needlecentervisisble === true){needlecentervisisble = false}
        else needlecentervisisble = true;

    }
    function togglering()
    {
        if (ringvisible === true){ringvisible = false}
        else ringvisible = true;
    }

    function warn()
    {

        if (gauge.value > roundGauge.warnvaluehigh || gauge.value < roundGauge.warnvaluelow)
        {
            roundGauge.warningcolor = "red";
            roundGauge.outerneedlecolortrail = "darkred";
            roundGauge.middleneedlecortrail =  "red";
            roundGauge.lowerneedlecolortrail = "orange";
            roundGauge.innerneedlecolortrail = "transparent";
            warningactive = 1;
        }
        else{
            roundGauge.warningcolor = "transparent";
            roundGauge.outerneedlecolortrail = outerneedlecolortrailsave;
            roundGauge.middleneedlecortrail = middleneedlecortrailsave;
            roundGauge.lowerneedlecolortrail = lowerneedlecolortrailsave;
            roundGauge.innerneedlecolortrail = innerneedlecolortrailsave;
            warningactive = 0;
        }
    }
}

