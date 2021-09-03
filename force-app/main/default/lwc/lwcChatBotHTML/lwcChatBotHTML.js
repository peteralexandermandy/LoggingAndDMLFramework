import BaseChatMessage from 'lightningsnapin/baseChatMessage';
import { track } from 'lwc';

const CHAT_CONTENT_CLASS = 'chat-content';
const AGENT_USER_TYPE = 'agent';
const CHASITOR_USER_TYPE = 'chasitor';
const SUPPORTED_USER_TYPES = [AGENT_USER_TYPE, CHASITOR_USER_TYPE];

/**
 * Displays a chat message that replaces links with custom text.
 */
export default class ShortenedLinksSample extends BaseChatMessage {
    @track messageStyle = '';
    @track text = '';

    isSupportedUserType(userType) {
        return SUPPORTED_USER_TYPES.some((supportedUserType) => supportedUserType === userType);
    }

    connectedCallback() {
        if (this.isSupportedUserType(this.userType)) {
            // Set our messageStyle class to decorate the message based on the user.
            this.messageStyle = `${CHAT_CONTENT_CLASS} ${this.userType}`;
            
            // Create a temporary element to strip out markup from the message.
            let element = document.createElement("div");
            element.innerHTML = this.messageContent.value;
            
            this.text = element.innerText

        } else {
            throw new Error(`Unsupported user type passed in: ${this.userType}`);
        }
    }
}