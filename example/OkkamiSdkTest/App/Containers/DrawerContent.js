// @flow

import React, { Component } from 'react'
import { ScrollView, Image, BackAndroid, View, Text, ListView,TouchableOpacity,TouchableHighlight } from 'react-native'
import Styles from './Styles/DrawerContentStyle'
import { Images, Colors, Metrics } from '../Themes'
import DrawerButton from '../Components/DrawerButton'
import { Actions as NavigationActions } from 'react-native-router-flux'
import Icon from 'react-native-vector-icons/FontAwesome'
import Panel from '../Components/Panel';


class DrawerContent extends Component {

  constructor(props) {
    super(props)
  }

  componentDidMount () {
    BackAndroid.addEventListener('hardwareBackPress', () => {
      if (this.context.drawer.props.open) {
        this.toggleDrawer()
        return true
      }
      return false
    })
  }

  toggleDrawer () {
    this.context.drawer.toggle()
  }

  handlePressLogin = () => {
    this.toggleDrawer()
    NavigationActions.login()
  }

  handlePressLobby = () => {
    this.toggleDrawer()
    NavigationActions.listviewExample()
  }

  handlePressControl = () => {
    this.toggleDrawer()
    NavigationActions.presentationScreen()
  }

  handlePromotionScreen = () => {
    this.toggleDrawer()
    NavigationActions.promotionScreen()
  }

  handleWebview(url){
    this.toggleDrawer()
    // NavigationActions.webview({url: 'http://www.kapook.com'})
    //NavigationActions.openWebView({url:url})
  }

  handleLandingScreen = () => {
    this.toggleDrawer()
    NavigationActions.landingScreen()
  }

  handleVideoScreen = () => {
    this.toggleDrawer()
    NavigationActions.videoScreen()
  }

  handleApiScreen = () => {
    this.toggleDrawer()
    NavigationActions.apiScreen()
  }

  handleApiTestScreen = () => {
    this.toggleDrawer()
    NavigationActions.apiTesting()
  }

  handlePresentationScreen= () => {
    this.toggleDrawer()
    NavigationActions.presentationScreen()
  }

  handleRoomControlsScreen= () => {
    this.toggleDrawer()
    NavigationActions.roomControlsScreen()
  }

  handlePressPresent= () => {
    this.toggleDrawer()
    NavigationActions.presentationScreen()
  }

  render () {
    return (
  <View style={Styles.container}>

        <View style={Styles.header}>
          <View style={Styles.headerLeft}>
            <Image
              // source={{uri:'https://s3.amazonaws.com/fingi/assets/thumbnail_guest_avatar-2f5072fba40190f1114c2dd37f3bb907.png'}}
              source={require('../Images/avatar.png')}
              style={Styles.avatar}
            />
          </View>
          <View style={Styles.headerRight}>
            <View style={Styles.headerRightTextTop}>
              <Text style={Styles.headerRightTextName}>Vivianne White</Text>
              <View style={{flex:1,height:30}}>
                {/* <Image
                  source={require('../Images/option.png')}
                  style={{width:30,height:30}}
                /> */}
                <Icon name='gear'
                      size={Metrics.icons.medium}
                      color={Colors.snow}
                      onPress={this.handleRoomControlsScreen}
                />
              </View>
            </View>
            <View style={Styles.headerRightTextButtom}>
              <Text style={Styles.headerRightTextRoom}>RM 100 | Okkami Test</Text>
            </View>

          </View>
        </View>

        <View style={Styles.mainMenu}>

          <ScrollView style={{
              flex            : 1,
              backgroundColor : Colors.fire,
              paddingTop      : 0}}
          >
            <Panel title="MY ACCOUNT" child="true" >
              <TouchableHighlight  underlayColor="#ffffff" onPress={this.handlePromotionScreen} >
                <View style={Styles.panelRow}>
                  <Text style={Styles.panelText}>Detail account</Text>
                </View>
              </TouchableHighlight>
              <TouchableHighlight  underlayColor="#ffffff" onPress={this.handleLandingScreen} >
                <View style={Styles.panelRow}>
                  <Text style={Styles.panelText}>Landing Screen</Text>
                </View>
              </TouchableHighlight>
            </Panel>

            <Panel title="OKKAMI CONCIERGE" child="false" onPress={this.handlePressLobby}>
              <View></View>
            </Panel>

            <Panel title="MY BOOKINGS" child="true" >
              <TouchableHighlight  underlayColor="#ffffff" onPress={this.handleWebview.bind(this,'http://whitelabel.dohop.com/w/okkami/')} >
                <View style={Styles.panelRow}>
                  <Text style={Styles.panelText}>FLIGHTS</Text>
                </View>
              </TouchableHighlight>
              <TouchableHighlight  underlayColor="#ffffff" onPress={this.handleWebview.bind(this,'http://www.booking.com/?aid=1151726')} >
                <View style={Styles.panelRow}>
                  <Text style={Styles.panelText}>HOTELS</Text>
                </View>
              </TouchableHighlight>
              <TouchableHighlight  underlayColor="#ffffff" onPress={this.handleWebview.bind(this,'https://www.partner.viator.com/en/19488')} >
                <View style={Styles.panelRow}>
                  <Text style={Styles.panelText}>ACTIVITES</Text>
                </View>
              </TouchableHighlight>
            </Panel>


          </ScrollView>

        </View>
      </View>
    )
  }

}

DrawerContent.contextTypes = {
  drawer: React.PropTypes.object
}

export default DrawerContent
