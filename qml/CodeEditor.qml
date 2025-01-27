import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15
import QtCharts 2.15
import QtQuick.Layouts 1.0
//import '../Js/highlightcolor.js' as Logic
import '../Js/prism.js' as Logic

Item{

    id:root

    Connections{
        enabled: true
        ignoreUnknownSignals: false
        target: backend

        function onColorhighlight(value){
            return value
        }
        function onFolderOpen(value){
            return JSON.stringify(value)
        }
    }

    property alias scode:editor
    readonly property real lineHeight: (editor.implicitHeight - 2 * editor.textMargin) / editor.lineCount
    readonly property alias lineCount: editor.lineCount
    //property alias gettext:editor.getText(0,editor.length)

    function verify(word,lst){
        var found=false
        for (let w of lst){
            if (w==word){
                //console.log(w)
                found=true
                break
            }
            else{
                found=false
            }
        }
        //console.log(found)
        return found
    }

    property int edit_height
    property int edit_width
    property color flk_color
    property color compcolor
    property alias code:editor.text
    property alias link:chemin.text

    Flickable {
        id: flickb
        y:25
        //anchors.fill: parent
        width:edit_width//parent.width-20 
        height: edit_height//parent.height-20
        anchors.centerIn: parent
        contentWidth: editor.paintedWidth
        contentHeight: editor.paintedHeight+300
        //flickDeceleration:-10
        maximumFlickVelocity : 700
        clip: true

        function ensureVisible(r)
        {
            if (contentX >= r.x)
                contentX = r.x;
            else if (contentX+width <= r.x+r.width)
                contentX = r.x+r.width-width;
            // if (contentY >= r.y)
            //     contentY = r.y//-(120;
            else if (contentY+height <= r.y+r.height)
                contentY = r.y+r.height-height;
        }

        // Rectangle{
        //     id:lines
        //     width:60
        //     height:(editor.lineCount*25)+parent.height
        //     anchors.left:parent.left
        //     color:barfonce

        //     Component{
        //         id:comp
        //         Rectangle{
        //             width:58
        //             height:25
        //             color:compcolor

        //             Text{
        //                 text:num
        //                 color:'white'
        //                 font.pixelSize:14
        //                 anchors.centerIn: parent
        //             }
        //             Rectangle{
        //                 width:parent.width
        //                 height:1
        //                 color:'black'
        //                 anchors.bottom:parent.bottom
        //             }
        //         }
        //     }

        //     ListModel{
        //         id:mod
        //         ListElement{
        //             num:1
        //         }
        //         dynamicRoles: false
        //     }

        //     ListView{
        //         y:5
        //         model:mod
        //         delegate:comp
        //         anchors.fill: parent
        //     }
        // }
        

        SuggestionBox {
            id: suggestionsBox
            //model: suggestions
            width: 200
            y: editor.cursorRectangle.y+15
            x: editor.cursorRectangle.left
            visible:false
            onItemSelected:{
                var i=item.text
                editor.selectWord()
                var l=editor.selectedText.length
                editor.cut()
                editor.cursorPosition=editor.cursorPosition
                if(i=='if'){
                    editor.insert(editor.cursorPosition,'if condition : ')
                    editor.cursorPosition-=3
                    editor.selectWord()
                }else{
                    editor.insert(editor.cursorPosition,i+' ')
                }
                //editor.insert(editor.cursorPosition,item.text.substr(editor.getCurrentWord().length,item.text.length-editor.getCurrentWord().length))//text.substr(item.name.length))//.replace(editor.text.substr(cursor,cursorPosition)
            }
        }
        
        
        TextEdit{
            id:editor
            focus:true
            width: flickb.width
            height: (lineCount*25)+flickb.height//flickb.height
            color:'white'
            mouseSelectionMode:TextEdit.SelectCharacters
            font.pixelSize:14
            font.family:'arial'//'monospace'
            selectByMouse: true
            selectionColor: '#254655C5'//'#1C98E0'
            tabStopDistance: 40
            textFormat: TextEdit.RichText
            property bool processing:false
            leftPadding :col.width//35
            //topPadding:2
            wrapMode: Text.WordWrap
            enabled:true
            property int currentLine: getText(0, cursorPosition).split('\u2029').length
            //selectedTextColor :'#060707'
            Shortcut {
                sequence: "Ctrl+H"
                onActivated: {
                    suggestionsBox.visible=true;
                }
            }
            
            function getCurrentWord(){
                var t=getText(0,cursorPosition)//.split(' ')
                var j=0
                var chars=[' ',',','\u2029','.','\u21E5','(',')','{','}','[',']','"',"'",'@',':','!','&','|','~','\t','\n']
                for(let i=t.length;i>0;i--){
                    if(root.verify(t.substr(i,1),chars)){
                        j=i
                        break
                    }
                }
                suggestionsBox.line=editor.currentLine
                suggestionsBox.pos=editor.cursorPosition
                suggestionsBox.code=getText(0,length)
                suggestionsBox.modeIndicator=t.substr(j,1)
                return t.substr(j+1,j-1)
            }

            onCursorRectangleChanged:{
                flickb.ensureVisible(cursorRectangle)
                suggestionsBox.ifilter=getCurrentWord()
            }

            function cursvisible() {
                if(cursorRectangle.y <editor.y){//Cursor went off the front
                    editor.y =  Math.max(0, cursorRectangle.y);
                }else if(cursorRectangle.y > parent.height - 20 - editor.y){//Cursor went off the end
                    editor.y =  Math.max(0, cursorRectangle.y - (parent.height - 20) + cursorRectangle.height);
                }
            }
            
            onTextChanged: {
                
                // AUTO BRACKET CLOSER
                // if(root.verify(getText(0,length).substr(cursorPosition-1,1),['\'','"','(','[','{'])){
                //     var comp_char=''
                //     if(getText(0,length).substr(cursorPosition-1,1)=="'"){
                //         comp_char="'"
                //     }else if(getText(0,length).substr(cursorPosition-1,1)=='"'){
                //         comp_char='"'
                //     }else if(getText(0,length).substr(cursorPosition-1,1)=='('){
                //         comp_char=')'
                //     }else if(getText(0,length).substr(cursorPosition-1,1)=='['){
                //         comp_char=']'
                //     }else if(getText(0,length).substr(cursorPosition-1,1)=='{'){
                //         comp_char='}'
                //     }
                //     //console.log(comp_char)
                //     insert(cursorPosition,comp_char)
                // }
                if(getText(0,cursorPosition).substr(cursorPosition-1,1)==' '||getText(0,cursorPosition).substr(cursorPosition-1,1)=='\u2029'||getText(0,cursorPosition).substr(cursorPosition-1,1)=='\u21E5'){
                    suggestionsBox.visible=false
                }else{
                    suggestionsBox.visible=true
                }
                if(getText(0,length).substr(cursorPosition-1,1)=='\u2029'){
                    var str=''
                    console.log(getText(0,cursorPosition));
                    var tt=backend.get_prev_indent_lvl(getText(0,cursorPosition))
                    var lvl=parseInt(tt)
                    console.log(lvl)
                    for(var i=0;i<lvl;i++){
                        str+='\u21E5'//'&#9;'
                    }
                    //tx.replace(tx.substr(0,cursorPosition),tt.split('[:--:]')[1])
                    insert(cursorPosition,str)
                    //cursorPosition+=lvl
                }
                
                if (!processing) {
                    processing = true;
                    let p = cursorPosition;
                    let l=text.length
                    var tx=getText(0, length)//.toString()
                    var t=backend.highlight(tx)

                    //console.log(t)"<link rel='stylesheet' href='../Js/style.css>"
                    text=t;
                    
                    
                    cursorPosition = p;
                    processing = false;
                }
            }
        }
        Rectangle{
            x:58
            y:editor.cursorRectangle.y
            color: 'transparent'//'#609EAD96'
            height: editor.cursorRectangle.height//root.lineHeight
            width: editor.width+200
            border.width:1
            border.color:bordercolor
            Rectangle{
                anchors.left:parent.left
                width:20
                height:parent.height
                color:'#609EAD96'
                visible:false
            }
        }
        Rectangle{
            y:0
            color: "#1E1E1F"//'transparent'//'#609EAD96'
            height: root.lineHeight/-5
            width: flickb.width
            visible: false
            Text{
                id:chemin
                font.pixelSize:11
                text:'the path to the file...'
                color:'white'
            }
        }
        Rectangle{
            height: childrenRect.height
            width: childrenRect.width
            color:'#1F1F20'
            Column {
                id:col
                // start position of line numbers depends on text margin
                y: 0//editor.textMargin
                width: 60//parent.width


                // add line numbers based on line count and height
                Repeater {
                    id:rep
                    model: editor.lineCount
                    delegate: Text {
                        id: text
                        width: implicitWidth
                        height: root.lineHeight
                        color: editor.getText(0, editor.cursorPosition).split('\u2029').length==parseInt(index+1)?"#FFFFFF":"#898A8B"//editor.cursorRectangle.y==y?"#FFFFFF":"#898A8B"
                        font: editor.font
                        text: index + 1
                        anchors.right:parent.right
                        anchors.margins: 15
                        MouseArea{
                            anchors.fill: parent
                            hoverEnabled:true

                            onClicked:{
                                parent.color='#26B83F'
                                console.log(editor.getText(0, editor.cursorPosition).split('\u2029').length,parent.text)
                            }
                        }
                    }
                }
            }
        }
        ScrollBar.vertical: ScrollBar {
            width:15
            active: flickb.moving || !flickb.moving
        }
        ScrollBar.horizontal: ScrollBar {
            height:15
            active: flickb.moving || !flickb.moving
        }
    }
}
