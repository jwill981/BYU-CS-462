import './App.css';
import { Switch, Route, Redirect, BrowserRouter } from "react-router-dom";
import Temperatures from "./Temperatures";
import Profile from "./Profile";


function App() {
  return (
    <BrowserRouter>
        <Route path="/" exact component={Temperatures} />
        <Route path="/profile" exact component={Profile} />
    </BrowserRouter>
  );
}

export default App;
