import { StyleSheet } from 'react-native'
import { Fonts, Colors, Metrics } from '../../Themes'

const width = Metrics.screenWidth
const height = Metrics.screenHeight

export default StyleSheet.create({
  container: {
    paddingTop: 50,
    backgroundColor: Colors.background,
    flex: 1
  },
  backgroundImage: {
    width: width,
    height: height,
    position: "absolute"
  },
  formScroll: {
    height:Metrics.screenHeight,
    width:Metrics.screenWidth,
    backgroundColor: Colors.windowTint,
  },
  formOver: {
    paddingTop:50,
    paddingBottom:50,
    width: width,
    // height: height,
    // position: "absolute",
    flexDirection: 'column',
    justifyContent: 'flex-start',
    alignItems: 'center'
  },
  textInput: {
    width: width/1.3,
    height: 40,
    borderRadius: 2,
    backgroundColor: Colors.snow,
    marginTop:10,
    textAlign: 'center',
  },
  selectInput:{
    width: width/1.3,
    height: 40,
    borderRadius: 2,
    backgroundColor: Colors.snow,
    marginTop:10,
  },
  buttonSnow: {
    width: width/1.3,
    height: 40,
    borderRadius: 5,
    marginHorizontal: Metrics.section,
    // marginVertical: Metrics.baseMargin,
    marginTop:10,
    backgroundColor: Colors.snow,
    justifyContent: 'center'
  },
  buttonFire: {
    width: width/1.3,
    height: 40,
    borderRadius: 5,
    marginHorizontal: Metrics.section,
    // marginVertical: Metrics.baseMargin,
    marginTop:10,
    backgroundColor: Colors.fire,
    justifyContent: 'center'
  },
  buttonText: {
    color: Colors.snow,
    textAlign: 'center',
    fontWeight: 'bold',
    fontSize: Fonts.size.medium,
    marginVertical: Metrics.baseMargin
  },
  buttonTextSnow: {
    color: Colors.coal,
    textAlign: 'center',
    fontWeight: 'bold',
    fontSize: Fonts.size.medium,
    marginVertical: Metrics.baseMargin
  },
  buttonCreate: {
    width: width/1.3,
    height: 45,
    borderRadius: 5,
    marginHorizontal: Metrics.section,
    marginTop:30,
    backgroundColor: Colors.fire,
    justifyContent: 'center'
  },
  sectionTextStyle:{
    fontWeight: 'bold',
    fontSize: Fonts.size.large,
  },
  selectTextStyle:{
    fontWeight: 'bold',
    fontSize: Fonts.size.medium,
  }

})
