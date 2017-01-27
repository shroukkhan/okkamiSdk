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
  Picker,
} from 'react-native'
import {connect} from 'react-redux'
import Styles from './Styles/SignUpScreenStyle'
import Img from './Styles/Images'
// import { Metrics } from '../Themes'
import {Actions as NavigationActions} from 'react-native-router-flux'
import ModalPicker from '../Components/Picker'

// I18n
import I18n from 'react-native-i18n'

class SignUpScreen extends React.Component {

  constructor(props) {
    super(props);
    this.state = {
      selectLanguage: '',
    }
  }

  handlePressLogin = () => {
    NavigationActions.login()
  }

  render() {
    let index = 0;
    const data = [
        { key: index++, section: true, label: 'Prefer Languages' },
        { key: index++, label: 'English' },
        { key: index++, label: 'Chinese' },
        { key: index++, label: 'Japanese' },
        { key: index++, label: 'Russian' },
    ];
    return (

      <View style={Styles.mainContainer}>
        <Image source={Img.backgroundOkkami} style={Styles.backgroundImage} />

        <ScrollView style={Styles.container} >
          <View style={Styles.formOver}>
            <View style={{justifyContent: 'center'}}>
              <TextInput
                ref='name'
                style={Styles.textInput}
                keyboardType='default'
                placeholder='First & LastName'
                underlineColorAndroid='transparent'
                returnKeyType='next' />
              <TextInput
                ref='email'
                style={Styles.textInput}
                keyboardType='email-address'
                placeholder='Email'
                underlineColorAndroid='transparent'
                returnKeyType='next' />
              <TextInput
                ref='phone'
                style={Styles.textInput}
                keyboardType='phone-pad'
                placeholder='Phone#'
                underlineColorAndroid='transparent'
                returnKeyType='next'/>
              <TextInput
                ref='hometown'
                style={Styles.textInput}
                keyboardType='default'
                underlineColorAndroid='transparent'
                placeholder='Hometown'/>
            </View>

            <ModalPicker
                style={Styles.selectInput}
                selectTextStyle={Styles.sectionTextStyle}
                sectionTextStyle={Styles.sectionTextStyle}
                selectStyle={{height:100}}
                data={data}
                initValue="Prefer Languages"
                onChange={(lang) => this.setState({selectLanguage: lang})} />
         
            <TouchableOpacity style={Styles.buttonSnow} onPress={NavigationActions.socialConnectionScreen}>
              <Text style={Styles.buttonTextSnow}>Social Connection</Text>
            </TouchableOpacity>
            <TouchableOpacity style={Styles.buttonSnow} onPress={NavigationActions.uploadPictureScreen}>
              <Text style={Styles.buttonTextSnow}>Avatar/Picture</Text>
            </TouchableOpacity>
            <TouchableOpacity style={Styles.buttonCreate} >
              <Text style={Styles.buttonText}>Create</Text>
            </TouchableOpacity>

          </View>
        </ScrollView>

      </View>

    )
  }

}

SignUpScreen.propTypes = {

}

SignUpScreen.defaultProps = {

}

const mapStateToProps = state => {
  return {

  }
}

const mapDispatchToProps = (dispatch) => {
  return {
  }
}

export default connect(mapStateToProps, mapDispatchToProps)(SignUpScreen)
