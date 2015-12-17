'use strict';

var React = require('react-native');
var { AppRegistry, Image, Text, Dimensions,View,StyleSheet,PropTypes,requireNativeComponent } = React;
var QuiltView = require('react-native-quiltview');
var Section = QuiltView.Section;
 var Item = QuiltView.Item;
var Cell = QuiltView.Cell;
var {Actions, Router, Route, Schema, Animations} = require('react-native-router-flux');
var NavigationBar = require('react-native-navbar');

// 详情页
var WebView = require('./WebView');

// 组件库
var Headline = require('./SlateComponents/Headline');
var NormalCell = require('./SlateComponents/NormalCell');
var Album = require('./SlateComponents/Album');
var slateComponents = {
    "headline" : Headline,
    "normalCell" : NormalCell,
    "album" : Album,
};

// 主界面
var Launch = React.createClass({

    getInitialState() {
        return {};
    },

    componentDidMount() {
        //var REQUEST_URL = 'http://www.baidu.com';
        //fetch(REQUEST_URL)
        //.then((response) => {
        //});

        this.setState({"layout" : {
            "nodeName" : "金融",
            "components" : [{
                "componentType" : "headline",
                "offset" : 1,
                "leaf" : { 
                        "leafName" : "leaf_1_1",
                        "updateTime" : "1448935284",
                        "title" : "“双12”袭来　丰田RAV4再掀购车狂潮",
                        "link" : "http://auto.ycwb.com/2015-12/14/content_20991507.htm",
                    }, 
                    "subComponents" : [{
                        "componentType" : "headlineCell",
                        "leaf" : { 
                            "leafName" : "leaf_1_1",
                            "updateTime" : "1448935284",
                            "picture" : "https://ss1.baidu.com/6ONXsjip0QIZ8tyhnq/it/u=2264917522,2698064010&fm=80",
                        }, 
                    },
                    {
                        "componentType" : "headlineCell",
                        "leaf" : { 
                            "leafName" : "leaf_1_2",
                            "updateTime" : "1448935284",
                            "picture" : "https://ss2.baidu.com/6ONYsjip0QIZ8tyhnq/it/u=2070245312,2918934520&fm=80",
                        },
                    },
                    {
                        "componentType" : "headlineCell",
                        "leaf" : { 
                            "leafName" : "leaf_1_3",
                            "updateTime" : "1448935284",
                            "picture" : "https://ss0.baidu.com/6ONWsjip0QIZ8tyhnq/it/u=2169543423,2641506640&fm=80",
                        },
                    }],
                },
                {
                    "componentType" : "normalCell",
                    "offset" : 2,
                    "leaf" : { 
                        "leafName" : "leaf_2",
                        "updateTime" : "1448935284",
                        "title" : "土耳其：无意就击落苏-24轰炸机对俄进行赔偿",
                        "picture" : "https://ss1.baidu.com/6ONXsjip0QIZ8tyhnq/it/u=1254653794,1787354139&fm=80",
                        "link" : "http://news.sohu.com/20151216/n431550866.shtml",
                    },
                },
                {
                    "componentType" : "normalCell",
                    "offset" : 3,
                    "leaf" : { 
                        "leafName" : "leaf_3",
                        "updateTime" : "1448935284",
                        "title" : "国内最难懂方言排行榜 你家乡上榜了没",
                        "link" : "http://www.kejixun.com/article/201512/143784.html",
                        "picture" : "https://ss1.baidu.com/6ONXsjip0QIZ8tyhnq/it/u=1732368520,3890924243&fm=80",
                    },
                },
                {
                    "componentType" : "album",
                    "offset" : 4,
                    "leaf" : { 
                        "leafName" : "leaf_4",
                        "updateTime" : "1448935284",
                        "title" : "习大大参观百度展台 李彦宏介绍无人车和百度翻译",
                        "link" : "http://tech.ifeng.com/a/20151216/41524711_0.shtml",
                    },
                    "subComponents" : [{
                        "componentType" : "albumCell",
                        "leaf" : { 
                            "leafName" : "leaf_4_1",
                            "updateTime" : "1448935284",
                            "picture" : "https://ss0.baidu.com/6ONWsjip0QIZ8tyhnq/it/u=2983569372,3003115457&fm=80",
                        },
                    },
                    {
                        "componentType" : "albumCell",
                        "leaf" : { 
                            "leafName" : "leaf_4_2",
                            "updateTime" : "1448935284",
                            "picture" : "https://ss0.baidu.com/6ONWsjip0QIZ8tyhnq/it/u=3478739337,2534079207&fm=80",
                        },
                    },
                    {
                        "componentType" : "albumCell",
                        "leaf" : { 
                            "leafName" : "leaf_4_3",
                            "updateTime" : "1448935284",
                            "picture" : "https://ss1.baidu.com/6ONXsjip0QIZ8tyhnq/it/u=3262148077,2591697069&fm=80",
                        }, 
                    }],
                }],
            }, 
            "mapping" : {
                "headline" : {
                    "title" : "leaf.title",
                    "url" : "leaf.link",
                },
                "album" : {
                    "title" : "leaf.title",
                    "url" : "leaf.link",
                },
                "albumCell" : {
                    "image" : "leaf.picture",
                },
                "headlineCell" : {
                    "image" : "leaf.picture",
                },
                "normalCell" : {
                    "title" : "leaf.title",
                    "image" : "leaf.picture",
                    "url" : "leaf.link",
                },
            }
        });
    },

    _renderRow(rowID : number, rowData : object) {
        // 动态加载组件
        var componentType = rowData.componentType;
        var type = slateComponents[componentType];
        return React.createElement(type, {key : "cell" + rowID, data : rowData, mapping : this.state.mapping});
    },

    render(){

        if (!this.state.layout) {
            return <View style={styles.container}><Text> loading ... </Text></View>;
        }

        var container = <QuiltView style={styles.container}></QuiltView>;
        var children = [];
        var sections = [];
        var components = this.state.layout.components;
 
        for (var rowID = 0; rowID < components.length; rowID++) {
            // 渲染数据
            var rowData = components[rowID];
            var row = this._renderRow(rowID, rowData);
            children.push(row); 
        };

        var sectionContainer = <Section label="1" key="section0"/>;
        var section = React.cloneElement(sectionContainer, {ref : 'quiltviewsection'}, children);

        sections.push(section);

        return React.cloneElement(container, {ref : 'quiltviewdemo'}, sections);
    }
});

var styles = StyleSheet.create({
  container: {
    flex: 1,
    flexDirection: 'row',
    backgroundColor: 'white',
    marginTop: 10,
  },
  cell: {
    flex: 1,
    flexDirection: 'row',
    backgroundColor: 'lightgray',
  },
  icon: {
    marginLeft: 15,
    marginTop: 10,
    width: 46,
    height: 46,
  },
  title: {
    textAlign: 'left',
    color: '#333333',
    marginTop: 10,
    marginLeft: 20,
    marginBottom: 10,
  },
  desc: {
    textAlign: 'left',
    color: '#333333',
    marginLeft: 20,
  },
});

// 导航条
class NavBar extends React.Component {
    render(){
        return <NavigationBar style={{backgroundColor: '#0db0d9'}}
                              titleColor='white'
                              buttonsColor='white'
                              statusBar='lightContent' {...this.props} />
    }
}

// 页面路由
class QuiltViewExample extends React.Component {
    render(){
        return (
            <Router>
                <Schema name="default" navBar={NavBar} sceneConfig={Animations.FlatFloatFromRight}/>
                <Route name="launch" component={Launch} title="QuiltView Demo"/>
                <Route name="news" component={WebView} title="News"/>
            </Router>
        );
    }
}

AppRegistry.registerComponent('QuiltViewExample', () => QuiltViewExample);
