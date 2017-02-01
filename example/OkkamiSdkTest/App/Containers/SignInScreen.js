import React, {PropTypes} from 'react'
import {
  View,
  ScrollView,
  Text,
  TextInput,
  TouchableOpacity,
  Image,
  Keyboard,
  LayoutAnimation,
} from 'react-native'
import {connect} from 'react-redux'
import Styles from './Styles/SignInScreenStyle'
import {Images, Metrics} from '../Themes'
import Img from './Styles/Images'
import {Actions as NavigationActions} from 'react-native-router-flux'
import Video  from 'react-native-video'
import OkkamiSdk from 'okkami-sdk'

// I18n
import I18n from 'react-native-i18n'

import Dimensions from 'Dimensions';

class SignInScreen extends React.Component {

  constructor(props) {
    super(props);
    this.state = {
      username: 'khan',
      password: '1234',
      selectLanguage: '',
      paused: false,
      rate: 1,
      volume: 1,
      muted: false,
      resizeMode: 'cover', //cover contain stretch
      duration: 0.0,
      currentTime: 0.0,
    }
    this.isAttempting = false
  }

  handlePressSignup = () => {
    NavigationActions.signUpScreen({type: "replace"})
  }

  handlePressLogin = () => {
    const {username, password} = this.state
    this.isAttempting = true
    console.log(username + " " + password)

    NavigationActions.landingScreen({type: "replace"})
  }

  render() {
    const {username, password} = this.state
    const {fetching} = this.props
    return (

      <View style={Styles.mainContainer}>
        <Image source={Img.backgroundOkkami} style={Styles.backgroundImage} />

         <TouchableOpacity style={Styles.backgroundVideo} onPress={() => {this.setState({paused: !this.state.paused})}}>
          {/* <Video source={{uri:'https://www.fingi.com/wp-content/uploads/2014/28/Aloft%20BKK%207%20FEB12.mov%20-%20Batch%20upload-20120207.mp4'}}  */}
          <Video source={Img.videoBg}
             style={Styles.backgroundVideo}
             rate={this.state.rate}
             paused={this.state.paused}
             volume={this.state.volume}
             muted={this.state.muted}
             resizeMode={this.state.resizeMode}
              // onLoad={this.onLoad}
              // onProgress={this.onProgress}
             onEnd={() => { console.log('Done!') }}
             repeat={false} />
        </TouchableOpacity>

        <ScrollView style={Styles.container} >        
        <View style={Styles.formOver}>
          <Image
            source={require('../Images/avatar.png')}
            style={Styles.avatar}
          />
          <TextInput
            ref='username'
            style={Styles.textInput}
            keyboardType='default'
            placeholder={I18n.t('username')}
            underlineColorAndroid='transparent'/>
          <TextInput
            ref='password'
            style={Styles.textInput}
            keyboardType='default'
            placeholder={I18n.t('password')}
            underlineColorAndroid='transparent'/>

          <View style={Styles.formButton}>
            <TouchableOpacity style={Styles.buttonFireSplitTwo} onPress={this.handlePressSignup} >
              <Text style={Styles.buttonText}>Sign Up</Text>
            </TouchableOpacity>

            {/* TODO login to core */}
            <TouchableOpacity style={Styles.buttonFireSplitTwo} onPress={this.handlePressLogin} >
              <Text style={Styles.buttonText}>Sign In</Text>
            </TouchableOpacity>
          </View>

          <TouchableOpacity style={Styles.buttonFire} >
            <Text style={Styles.buttonText}>Social Login</Text>
          </TouchableOpacity>

        </View>
        </ScrollView>

      </View>
    )
  }

}

SignInScreen.propTypes = {
  // dispatch: PropTypes.func,
  // fetching: PropTypes.bool,
  // error: PropTypes.string,
  // loggedIn: PropTypes.bool,
  // attemptLogin: PropTypes.func
}

SignInScreen.defaultProps = {
  // loggedIn: false,
  // fetching: false,
}

const mapStateToProps = state => {
  return {
    // fetching: false,
    // error: null,
    // loggedIn: false,
  }
}

const mapDispatchToProps = (dispatch) => {
  return {

    // attemptLogin: (username, password) => dispatch(OkkamiSdk.connectToRoom(username, password))
  }
}

export default connect(mapStateToProps, mapDispatchToProps)(SignInScreen)
