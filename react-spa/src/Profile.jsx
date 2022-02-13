import React , {Component} from "react";

var EVENT_URL = "http://192.168.1.89:3000/sky/event/ckydis6jm003vpdpu2glhdcst/test/"

export class Profile extends Component {
    constructor(props) {
        super(props);
        this.state = {
          name: null,
          location: null,
          phoneNumber: null,
          threshold: null,
          data: null
        };
    }

    handleChange = (event) => {
        console.log(event)
        this.setState({
            [event.target.id]: event.target.value,
          });
    }

    handleSubmit = (event) => {
        event.preventDefault();

        var data = {
            "name": this.state.name,
            "location": this.state.location,
            "smsNum": this.state.smsNum,
            "threshold": this.state.threshold
        }

        this.setState({
            data: data
        });

        fetch(EVENT_URL + "sensor/profile_updated?name=" + this.state.name + "&location=" + this.state.location + "&smsNum=" + this.state.phoneNumber + "&threshold=" + this.state.threshold)
            
    }

    render() {
        return (
            <div className="container text-center">
                { this.state.data ?
                    <div>
                        <h4>Name: {this.state.name}</h4>
                        <h4>Location: {this.state.location}</h4>
                        <h4>Phone: {this.state.phoneNumber}</h4>
                        <h4>Threshold: {this.state.threshold}</h4>
                    </div>
                :
                    <div>
                        No current data. Please enter profile information below.
                    </div>
                }

                <form onSubmit={this.handleSubmit}>
                    <label>Name: 
                        <input type="text" id="name" value={this.state.name} onChange={this.handleChange}/>
                    </label><br/>
                    <label>Location:
                        <input type="text" id="location" value={this.state.location} onChange={this.handleChange} />
                    </label><br/>
                    <label>Contact Number:
                        <input type="text" id="phoneNumber" value={this.state.phoneNumber} onChange={this.handleChange}/>
                    </label><br/>
                    <label>Threshold Temperature:
                        <input type="text" id="threshold" value={this.state.threshold} onChange={this.handleChange} />
                    </label><br/>
                    <button type="submit">Update Profile</button>
                </form>

            </div>
        )
    }
}

export default Profile;