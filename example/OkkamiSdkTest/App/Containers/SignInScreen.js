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
import {Actions as NavigationActions} from 'react-native-router-flux'
import Video  from 'react-native-video'

// I18n
import I18n from 'react-native-i18n'

import Dimensions from 'Dimensions';

class SignInScreen extends React.Component {

  constructor(props) {
    super(props);
    this.state = {
      selectLanguage: '',
      paused: false,
      rate: 1,
      volume: 1,
      muted: false,
      resizeMode: 'cover', //cover contain stretch
      duration: 0.0,
      currentTime: 0.0,
    }
  }

  handlePressSignup = () => {
    NavigationActions.signUpScreen({type: "replace"})
  }

  render() {

    return (

      <View style={Styles.container}>
        <Image source={require('../Images/okkami.png')} style={Styles.backgroundImage} />

        {/* video not config for on ios  */}
        <TouchableOpacity style={Styles.backgroundVideo} onPress={() => {this.setState({paused: !this.state.paused})}}>
          {/* <Video source={require("../Videos/thailand.mp4")} */}
          <Video source={{uri:'https://www.fingi.com/wp-content/uploads/2014/28/Aloft%20BKK%207%20FEB12.mov%20-%20Batch%20upload-20120207.mp4'}}
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
        <ScrollView style={Styles.formScroll} >        
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
            <TouchableOpacity style={Styles.buttonFireSplitTwo} >
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

}

SignInScreen.defaultProps = {

}

const mapStateToProps = state => {
  return {

  }
}

const mapDispatchToProps = (dispatch) => {
  return {

  }
}

export default connect(mapStateToProps, mapDispatchToProps)(SignInScreen)
