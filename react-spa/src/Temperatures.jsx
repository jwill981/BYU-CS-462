import React , {Component} from "react";

var CLOUD_URL = "http://192.168.1.89:3000/sky/cloud/ckydis6jm003vpdpu2glhdcst/"

export class Temperatures extends Component {
    constructor(props) {
        super(props);
        this.state = {
          temps: [],
          violations: [],
          currTemp: null
        };
    }

    componentDidMount() {
        this.getData();
    }

    getData() {
        fetch(CLOUD_URL + "temperature_store/temperatures")
            .then(res => res.json())
            .then(
              (response) => {
                this.setState({
                    temps: response
                })
              }
            )

        fetch(CLOUD_URL+ "temperature_store/threshold_violations")
            .then(res => res.json())
            .then(
                (response) => {
                    this.setState({
                        violations: response
                    })
                }
            )

        fetch(CLOUD_URL + "wovyn_base/currTemp")
            .then(res => res.json())
            .then(
                (response) => {
                    this.setState({
                        currTemp: response
                    })
                }
            )
    }

    render() {
        return (
            <div className="container" >
                <div className="row">
                    <div className="col-md-4">
                        <h1>Current Temp:</h1>
                        <h4>{this.state.currTemp}</h4>
                    </div>

                    <div className="col-md-4">
                        <h1>Threshold Violations:</h1>
                        { this.state.violations.map(violation => (
                            <div>
                                <h4>{violation.temp}</h4>
                                <p>{violation.timestamp}</p>
                            </div>
                        ))}
                    </div>

                    <div className="col-md-4">
                        <h1>All Temps:</h1>
                        { this.state.temps.map(temp => (
                            <div>
                                <h4>{temp.temp} F</h4>
                                <p>{temp.timestamp}</p>
                            </div>
                        ))}
                    </div>
                </div>

            </div>
        )
    }
    
}

export default Temperatures;