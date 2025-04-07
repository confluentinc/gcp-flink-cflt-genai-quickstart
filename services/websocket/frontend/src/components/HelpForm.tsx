import { Help } from '@/pages/Help'
import archImage from '/Users/puyar/repos/gcp-flink-cflt-genai-quickstart/services/websocket/frontend/src/assets/arch.png';
import ccApiKeyGif from '/Users/puyar/repos/gcp-flink-cflt-genai-quickstart/services/websocket/frontend/src/assets/cc-api-keys.gif';
import ccApiKeyImage from '/Users/puyar/repos/gcp-flink-cflt-genai-quickstart/services/websocket/frontend/src/assets/cc-api-keys.png';
import gcpEnableApiGif from '/Users/puyar/repos/gcp-flink-cflt-genai-quickstart/services/websocket/frontend/src/assets/gcp-enable-api.gif';
import gcpGeminiKeyGif from '/Users/puyar/repos/gcp-flink-cflt-genai-quickstart/services/websocket/frontend/src/assets/gcp-gemini-key.gif';
import usernamePasswordGif from '/Users/puyar/repos/gcp-flink-cflt-genai-quickstart/services/websocket/frontend/src/assets/username:password.gif';

const ScrollLink = ({ to, title }) => {
  const handleClick = (e) => {
    e.preventDefault();
    const section = document.getElementById(to);
    if(section) {
      section.scrollIntoView();
    }
  };

  return (
    <a href={`#/${to}`} onClick={handleClick} title={title}>
      {title}
    </a>
  );
};

export const HelpForm = () => {
    return (
            <>
              <meta charSet="UTF-8" />
              <title>Document</title>
              <meta httpEquiv="X-UA-Compatible" content="IE=edge,chrome=1" />
              <meta name="description" content="Description" />
              <meta
                name="viewport"
                content="width=device-width, initial-scale=1.0, minimum-scale=1.0"
              />
              <link
                rel="stylesheet"
                href="//cdn.jsdelivr.net/npm/docsify@4/lib/themes/buble.css"
              />
              <main style={{ display: 'flex', height: '100vh', overflow: 'hidden' }}>
                <button className="sidebar-toggle" aria-label="Menu">
                  <div className="sidebar-toggle-button">
                    <span />
                    <span />
                    <span />
                  </div>
                </button>
                <aside className="sidebar" style={{ height: '100vh', overflowY: 'auto', flexBasis: '20%', flexGrow: 0, flexShrink: 0 }}>
                  <div className="sidebar-nav">
                    <ul>
                      <li className="active">
                        <ScrollLink to="genai-healthcare-quickstart" title="GenAI Healthcare Quickstart" />
                      </li>
                      <ul>
                        <li className="">
                          <ScrollLink to="table-of-contents" title="Table of Contents" />
                        </li>
                        <li className="">
                          <ScrollLink to="key-features" title="Key Features" />
                        </li>
                        <li className="">
                          <ScrollLink to="use-case" title="Use Case" />
                        </li>
                        <li className="">
                          <ScrollLink to="architecture" title="Architecture" />
                        </li>
                        <ul>
                          <li className="">
                            <ScrollLink to="natural-language-voice-assistant" title="Natural Language Voice Assistant" />
                          </li>
                          <li className="">
                            <ScrollLink to="key-concepts" title="Key Concepts" />
                          </li>
                          <ul>
                            <li className="">
                              <ScrollLink to="docker" title="Docker" />
                            </li>
                          </ul>
                        </ul>
                        <li className="">
                          <ScrollLink to="requirements" title="Requirements" />
                        </li>
                        <li className="">
                          <ScrollLink to="access-keys-to-cloud-services-providers" title="Access Keys to Cloud Services Providers" />
                        </li>
                        <ul>
                          <li className="">
                            <ScrollLink to="confluent-cloud" title="Confluent Cloud" />
                          </li>
                          <li className="">
                            <ScrollLink to="gcp" title="GCP" />
                          </li>
                        </ul>
                        <li className="">
                          <ScrollLink to="run-the-quickstart" title="Run The Quickstart" />
                        </li>
                        <ul>
                          <li className="">
                            <ScrollLink to="_1-bring-up-the-infrastructure" title="1. Bring Up The Infrastructure" />
                          </li>
                          <li className="">
                            <ScrollLink to="_2-have-a-conversation" title="2. Have a conversation!" />
                          </li>
                          <ul>
                            <li className="">
                              <ScrollLink to="_2a-example-conversations" title="2a. Example Conversations" />
                            </li>
                          </ul>
                          <li className="">
                            <ScrollLink to="_3-bring-down-the-infrastructure" title="3. Bring down the infrastructure" />
                          </li>
                        </ul>
                        <li className="">
                          <ScrollLink to="faq" title="FAQ" />
                        </li>
                        <ul>
                          <li className="">
                            <ScrollLink to="when-i-run-destroysh-i-encounter-gcp-reauth-needed-error-how-can-i-solve-this-problem" title="When I run destroy.sh I encounter gcp reauth needed error. How can I solve this problem?" />
                          </li>
                          <li>
                            <ScrollLink to="where-can-i-see-my-deployed-kstreams-apps" title="Where can I see my deployed kstreams apps?" />
                          </li>
                          <li>
                            <ScrollLink to="which-deploysh-and-destroysh-should-i-run" title="Which deploy.sh and destroy.sh should I run?" />
                          </li>
                          <li>
                            <ScrollLink to="is-there-a-shortcut-to-pass-environment-variables-once-instead-providing-them-every-time-i-deploy" title="Is there a shortcut to pass environment variables once instead providing them every time I deploy?" />
                          </li>
                          <li>
                            <ScrollLink to="i-am-hitting-quoterror-error-reading-kafka-topic-401-api-key-based-authentication-failed-api-key-based-authentication-failedquot-error-while-rotating-my-keys-how-can-i-fix-this" title="I am hitting Error: error reading Kafka Topic: 401 API-key based authentication failed.: API-key based authentication failed. error while rotating my keys. How can I fix this?" />
                          </li>
                        </ul>
                        <li>
                          <ScrollLink to="next-steps-improving-the-results" title="Next Steps - Improving the Results" />
                        </li>
                      </ul>
                    </ul>
                  </div>
                </aside>
                <section className="content" style={{ flexGrow: 1, overflowY: 'auto', flexBasis: '80%' }}>
                  <article className="markdown-section" id="main">
                    <h1 id="genai-healthcare-quickstart">
                      <a
                        data-id="genai-healthcare-quickstart"
                      >
                        <span>GenAI Healthcare Quickstart</span>
                      </a>
                    </h1>
                    <p>
                      Welcome to the GenAI Healthcare Quickstart! This repository provides a
                      step-by-step guide for deploying a fully functional Natural Language
                      Voice Assistant in the healthcare domain.{" "}
                    </p>
                    <p>
                      Leveraging Confluent Cloud for real-time data streaming and Google
                      Cloud Platform for advanced AI (via “Gemini” models) and data
                      warehousing (BigQuery), this solution demonstrates how to build an
                      intelligent, scalable, and cloud-native conversational experience.
                    </p>
                    <h2 id="table-of-contents">
                      <a
                        data-id="table-of-contents"
                      >
                        <span>Table of Contents</span>
                      </a>
                    </h2>
                    <ul>
                      <li>
                        <ul>
                          <li>
                            <ScrollLink to="key-features" title="Key Features" />
                          </li>
                          <li>
                            <ScrollLink to="use-case" title="Use Case" />
                          </li>

                          <li>
                            <ScrollLink to="architecture" title="Architecture" />
                            <ul>
                              <li>
                                <ScrollLink to="natural-language-voice-assistant" title="Natural Language Voice Assistant" />
                              </li>
                              <li>
                                <ScrollLink to="key-concepts" title="Key Concepts" />
                              </li>
                            </ul>
                          </li>
                          <li>
                            <ScrollLink to="requirements" title="Requirements" />
                            <ul>
                              <li>
                                <ScrollLink to="docker" title="Docker" />
                              </li>
                              <li>
                                <ScrollLink to="access-keys-to-cloud-services-providers" title="Access Keys to Cloud Services Providers" />
                                <ul>
                                  <li>
                                    <ScrollLink to="confluent-cloud" title="Confluent-Cloud" />
                                  </li>
                                  <li>
                                    <ScrollLink to="gcp" title="GCP" />
                                  </li>
                                </ul>
                              </li>
                            </ul>
                          </li>
                          <li>
                            <ScrollLink to="run-the-quickstart" title="Run the Quickstart" />
                            <ul>
                              <li>
                                <ScrollLink to="_1-bring-up-the-infrastructure" title="1. Bring Up The Infrastructure" />
                              </li>
                              <li>
                                <ScrollLink to="_2-have-a-conversation" title="2. Have a conversation" />
                                <ul>
                                  <li>
                                    <ScrollLink to="_2a-example-conversations" title="2a. Example Conversations" />
                                  </li>
                                </ul>
                              </li>
                              <li>
                                <ScrollLink to="_3-bring-down-the-infrastructure" title="3. Bring down the infrastructure" />
                              </li>
                            </ul>
                          </li>
                          <li>
                            <ScrollLink to="faq" title="FAQ" />
                          </li>
                          <li>
                            <ScrollLink to="next-steps---improving-the-results" title="Next Steps - Improving the Results" />
                          </li>
                        </ul>
                      </li>
                    </ul>
                    <h2 id="key-features">
                      <a
                        data-id="key-features"
                      >
                        <span>Key Features</span>
                      </a>
                    </h2>
                    <ul>
                      <li>
                        <strong>Real-Time Data Processing</strong>: Powered by Confluent
                        Cloud and Kstreams App, ensuring low-latency communication and
                        event-driven architecture.
                      </li>
                      <li>
                        <strong>Intelligent Conversations</strong>: Integrated with GCP
                        Gemini AI models for natural and accurate conversational responses.
                      </li>
                      <li>
                        <strong>Efficient Information Retrieval</strong>: Leverages BigQuery
                        with vector search capabilities for quick and accurate document
                        indexing and retrieval.
                      </li>
                      <li>
                        <strong>Scalable and Cloud-Native</strong>: Built with modern cloud
                        architecture to ensure high availability, elasticity, and effortless
                        scaling.
                      </li>
                      <li>
                        <strong>Seamless Deployment</strong>: Follow step-by-step
                        instructions to deploy the entire solution with minimal effort.
                      </li>
                    </ul>
                    <h2 id="use-case">
                      <a>
                        <span>Use Case</span>
                      </a>
                    </h2>
                    <p>
                      This Natural Language Voice Assistant is tailored for healthcare
                      workers as a patient pre-screening application. Possible uses cases
                      are:
                    </p>
                    <ul>
                      <li>
                        Enable doctors to request a comprehensive summary of a patient's
                        medical records before their scheduled appointment. The generated
                        summary will provide the doctor with all relevant and essential
                        information needed to facilitate informed decision-making during the
                        consultation.
                      </li>
                      <li>
                        Ensuring that critical patient data—such as past diagnoses,
                        medications, allergies, and recent test results—is readily available
                        in a concise and accessible format.
                      </li>
                      <li>Streamline the pre-appointment review process.</li>
                    </ul>
                    <p>
                      👉 Please note that this quick start builds a working AI
                      infrastructure for you, but it's fueled by a small quantity of fake
                      data, so the results won't be at the level that you're accustomed to
                      with AI applications such as ChatGPT. Read the Next Steps section at
                      the end of this document to find out how you can tweak the
                      architecture and improve or alter the AI results.
                    </p>
                    <h2 id="architecture">
                      <a

                        data-id="architecture"

                      >
                        <span>Architecture</span>
                      </a>
                    </h2>
                    <p>
                      <strong>
                        Future modifications to this Architecture diagram will be made.
                      </strong>
                    </p>
                    <p>
                      Architecture for handling audio, summarizing, building &amp; executing
                      query and chatbot functionality using a combination of Flink, Kafka
                      Streams and Google APIs . Below is a breakdown of the architecture and
                      its components:
                      <img src={archImage} alt="Architecture Diagram" />
                    </p>
                    <h3 id="natural-language-voice-assistant">
                      <a

                        data-id="natural-language-voice-assistant"

                      >
                        <span>Natural Language Voice Assistant</span>
                      </a>
                    </h3>
                    <p>
                      This section demonstrates how the system interacts with user queries
                      in real time.
                    </p>
                    <ol>
                      <li>
                        <strong>Frontend:</strong> The frontend handles interactions with
                        users. User audios are sent to a topic for further processing.
                      </li>
                      <li>
                        <strong>Websocket:</strong> Provides real-time communication between
                        the frontend and backend for immediate responses.
                      </li>
                      <li>
                        <strong>Model Inference:</strong> Google Gemini is used for model
                        inference to generate responses.
                      </li>
                      <li>
                        <strong>Output to User:</strong> The system sends the processed
                        results back to the user via the websocket.
                      </li>
                    </ol>
                    <h3 id="key-concepts">
                      <a

                        data-id="key-concepts"

                      >
                        <span>Key Concepts</span>
                      </a>
                    </h3>
                    <ol>
                      <li>
                        <p>
                          <strong>Embeddings:</strong> These are vector representations of
                          text, allowing the system to handle semantic search.
                        </p>
                      </li>
                      <li>
                        <p>
                          <strong>Google Gemini:</strong> Used for both summarization and
                          generating responses in natural language.
                        </p>
                      </li>
                    </ol>
                    <h2 id="requirements">
                      <a

                        data-id="requirements"

                      >
                        <span>Requirements</span>
                      </a>
                    </h2>
                    <h4 id="docker">
                      <a data-id="docker">
                        <span>Docker</span>
                      </a>
                    </h4>
                    <p>
                      The <code>deploy</code> script automates the entire build process; the
                      only required software is Docker. Docker can be installed by following
                      the official instructions -{" "}
                      <a
                        href="https://docs.docker.com/get-docker/"
                        target="_blank"
                        rel="noopener"
                      >
                        Get Docker
                      </a>
                      .
                    </p>
                    <hr />
                    <h2 id="access-keys-to-cloud-services-providers">
                      <a

                        data-id="access-keys-to-cloud-services-providers"

                      >
                        <span>Access Keys to Cloud Services Providers</span>
                      </a>
                    </h2>
                    <p>
                      After installing <code>docker</code>, the next step is to obtain the
                      necessary authentication keys for the respective cloud service
                      providers (CSPs).
                    </p>
                    <h3 id="confluent-cloud">
                      <a

                        data-id="confluent-cloud"

                      >
                        <span>Confluent Cloud</span>
                      </a>
                    </h3>
                    <p>
                      <img src={ccApiKeyGif} alt="Creating Confluent Cloud Api Keys" />
                    </p>
                    <p>
                      For Confluent Cloud, a <em>Cloud Resource Management</em> API key is
                      required.
                    </p>
                    <p>
                      If an account is not already set up, sign up first. Then, navigate to
                      the top-right corner menu (also known as the hamburger menu) and
                      select <em>API Keys</em> to generate the required key.
                    </p>
                    <p>
                      <img src={ccApiKeyImage} alt="Creating Confluent Cloud Api Keys Image" />
                    </p>
                    <p>
                      Click the <em>+ Add API key</em> button, select <em>My Account</em>{" "}
                      and click the <em>Next</em> button (bottom right). If you feel like
                      it, enter a name and description. Click the <em>Create API Key</em>{" "}
                      (bottom right).
                    </p>
                    <hr />
                    <h3 id="gcp">
                      <a>
                        <span>GCP</span>
                      </a>
                    </h3>
                    <p>
                      <img src={gcpGeminiKeyGif} alt="Creating Gemini Keys" />
                    </p>
                    <p>
                      For Google Cloud, both a <strong>Gemini API Key</strong> and the{" "}
                      <strong>Project ID</strong> are required.
                    </p>
                    <p>
                      If an account hasn’t been created yet, sign up and navigate to the{" "}
                      <em>Console</em> screen. The <strong>Project ID</strong> will be
                      displayed just below the welcome message—be sure to save this for
                      later use.
                    </p>
                    <p>
                      Next, open the top-left menu and select{" "}
                      <strong>APIs &amp; Services</strong>.<br />
                      Click the <strong>Credentials</strong> tab on the left, then click{" "}
                      <strong>+ Create Credentials</strong> and choose{" "}
                      <strong>API Key</strong>.<br />
                      Save this API key, as it will be required by the application when
                      running the <code>deploy.sh</code> script.
                    </p>
                    <p>
                      If not enabled yet please navigate to the{" "}
                      <strong>+Enable APIs and Services</strong> tab to enable APIs below.
                    </p>
                    <ul>
                      <li>Artifact Registry API</li>
                      <li>Cloud Build API</li>
                      <li>Cloud Run Admin API</li>
                    </ul>
                    <p>
                      <img src={gcpEnableApiGif} alt="Enabling APIs on GCP" />
                    </p>
                    <blockquote>
                      <p>
                        [!NOTE] In case you see MANAGE instead of ENABLE that means these
                        APIs are already enabled.
                      </p>
                    </blockquote>
                    <hr />
                    <h2 id="run-the-quickstart">
                      <a

                        data-id="run-the-quickstart"

                      >
                        <span>Run the Quickstart</span>
                      </a>
                    </h2>
                    <h3 id="_1-bring-up-the-infrastructure">
                      <a

                        data-id="_1-bring-up-the-infrastructure"

                      >
                        <span>1. Bring up the infrastructure</span>
                      </a>
                    </h3>
                    <pre v-pre="" data-lang="">
                      <code className="lang-">
                        ./deploy.sh{"\n"}# Follow the prompts to enter your API keys and
                        other credentials
                      </code>
                    </pre>
                    <pre v-pre="" data-lang="">
                      <code className="lang-">
                        GCP_REGION = "
                        <span className="token tag">
                          <span className="token tag">
                            <span className="token punctuation">&lt;</span>region
                          </span>{" "}
                          <span className="token attr-name">of</span>{" "}
                          <span className="token attr-name">your</span>{" "}
                          <span className="token attr-name">GCP</span>{" "}
                          <span className="token attr-name">project</span>
                          <span className="token punctuation">&gt;</span>
                        </span>
                        "{"\n"}GCP_PROJECT_ID = "
                        <span className="token tag">
                          <span className="token tag">
                            <span className="token punctuation">&lt;</span>project
                          </span>{" "}
                          <span className="token attr-name">id</span>{" "}
                          <span className="token attr-name">of</span>{" "}
                          <span className="token attr-name">your</span>{" "}
                          <span className="token attr-name">GCP</span>{" "}
                          <span className="token attr-name">-</span>{" "}
                          <span className="token attr-name">you</span>{" "}
                          <span className="token attr-name">have</span>{" "}
                          <span className="token attr-name">retrieved</span>{" "}
                          <span className="token attr-name">above</span>
                          <span className="token punctuation">&gt;</span>
                        </span>
                        "{"\n"}GCP_GEMINI_API_KEY = "
                        <span className="token tag">
                          <span className="token tag">
                            <span className="token punctuation">&lt;</span>GCP
                          </span>{" "}
                          <span className="token attr-name">Gemini</span>{" "}
                          <span className="token attr-name">API</span>{" "}
                          <span className="token attr-name">Key</span>{" "}
                          <span className="token attr-name">-</span>{" "}
                          <span className="token attr-name">you</span>{" "}
                          <span className="token attr-name">have</span>{" "}
                          <span className="token attr-name">retrieved</span>{" "}
                          <span className="token attr-name">above</span>
                          <span className="token punctuation">&gt;</span>
                        </span>
                        "{"\n"}GCP_ACCOUNT = "
                        <span className="token tag">
                          <span className="token tag">
                            <span className="token punctuation">&lt;</span>email
                          </span>{" "}
                          <span className="token attr-name">on</span>{" "}
                          <span className="token attr-name">your</span>{" "}
                          <span className="token attr-name">GCP</span>{" "}
                          <span className="token attr-name">account</span>
                          <span className="token punctuation">&gt;</span>
                        </span>
                        "{"\n"}
                        {"\n"}CONFLUENT_CLOUD_API_KEY = "
                        <span className="token tag">
                          <span className="token tag">
                            <span className="token punctuation">&lt;</span>Confluent
                          </span>{" "}
                          <span className="token attr-name">Cloud</span>{" "}
                          <span className="token attr-name">API</span>{" "}
                          <span className="token attr-name">Key</span>{" "}
                          <span className="token attr-name">-</span>{" "}
                          <span className="token attr-name">you</span>{" "}
                          <span className="token attr-name">have</span>{" "}
                          <span className="token attr-name">retrieved</span>{" "}
                          <span className="token attr-name">above</span>
                          <span className="token punctuation">&gt;</span>
                        </span>
                        "{"\n"}CONFLUENT_CLOUD_API_SECRET = "
                        <span className="token tag">
                          <span className="token tag">
                            <span className="token punctuation">&lt;</span>Confluent
                          </span>{" "}
                          <span className="token attr-name">Cloud</span>{" "}
                          <span className="token attr-name">API</span>{" "}
                          <span className="token attr-name">Secret</span>{" "}
                          <span className="token attr-name">-</span>{" "}
                          <span className="token attr-name">you</span>{" "}
                          <span className="token attr-name">have</span>{" "}
                          <span className="token attr-name">retrieved</span>{" "}
                          <span className="token attr-name">above</span>
                          <span className="token punctuation">&gt;</span>
                        </span>
                        "{"\n"}CONFLUENT_CLOUD_REGION = "
                        <span className="token tag">
                          <span className="token tag">
                            <span className="token punctuation">&lt;</span>Confluent
                          </span>{" "}
                          <span className="token attr-name">Cloud</span>{" "}
                          <span className="token attr-name">region</span>{" "}
                          <span className="token attr-name">-</span>{" "}
                          <span className="token attr-name">
                            <span className="token namespace">default:</span>us-east1
                          </span>
                          <span className="token punctuation">&gt;</span>
                        </span>
                        "
                      </code>
                    </pre>
                    <h3 id="_2-have-a-conversation">
                      <a
                        data-id="_2-have-a-conversation"
                      >
                        <span>2. Have a conversation!</span>
                      </a>
                    </h3>
                    <p>
                      Once the infrastructure is deployed, the Natural Language Assistant
                      can be accessed by opening the frontend URL generated by Terraform.
                    </p>
                    <p>For example, if the Terraform output is: </p>
                    <pre v-pre="" data-lang="">
                      <code className="lang-">
                        Service URL:
                        "https://quickstart-healthcare-ai-websocket-zsvndjdv4-666664333300.us-east1.run.app"
                      </code>
                    </pre>
                    <p>
                      For the purposes of this quickstart, any email and password will be
                      accepted, and after you log in to have a conversation hit the record
                      button.
                      <img src={usernamePasswordGif} alt="Username:Password" />
                    </p>
                    <h4 id="_2a-example-conversations">
                      <a
                        data-id="_2a-example-conversations"
                      >
                        <span>2a. Example Conversations</span>
                      </a>
                    </h4>
                    <blockquote>
                      <p>
                        [!IMPORTANT] Please keep in mind that for the sake of this
                        quickstart you are the healthcare worker who would like to get the
                        appointment related information of your patient.
                      </p>
                    </blockquote>
                    <p>
                      Let's assume the patient's name we have an appointment is Justin
                      Evans. Here are some example questions to ask:
                    </p>
                    <ul>
                      <li>
                        What are the summaries of recent appointments with Justin Evans?
                      </li>
                      <li>What type of medicine Justin Evans uses currently?</li>
                      <li>
                        What is the last diagnosis at the latest appointment of Justin
                        Evans?
                      </li>
                    </ul>
                    <h3 id="_3-bring-down-the-infrastructure">
                      <a

                        data-id="_3-bring-down-the-infrastructure"

                      >
                        <span>3. Bring down the infrastructure</span>
                      </a>
                    </h3>
                    <blockquote>
                      <p>
                        [!CAUTION] Running this script will remove all previously deployed
                        resources, including cloud infrastructure, data platform assets, and
                        streaming applications, ensuring a clean state for subsequent use.
                      </p>
                    </blockquote>
                    <pre v-pre="" data-lang="">
                      <code className="lang-">./destroy.sh</code>
                    </pre>
                    <h2 id="faq">
                      <a>
                        <span>FAQ</span>
                      </a>
                    </h2>
                    <h3 id="when-i-run-destroysh-i-encounter-gcp-reauth-needed-error-how-can-i-solve-this-problem">
                      <a
                        data-id="when-i-run-destroysh-i-encounter-gcp-reauth-needed-error-how-can-i-solve-this-problem"
                      >
                        <span>
                          When I run destroy.sh I encounter{" "}
                          <strong>gcp reauth needed</strong> error. How can I solve this
                          problem?
                        </span>
                      </a>
                    </h3>
                    <p>
                      The credentials associated with the session have expired due to a
                      timeout. Reauthentication is not enabled while you have an existing{" "}
                      <strong>.config</strong> file. Try deleting both{" "}
                      <strong>.config</strong> files under <code>root</code> and{" "}
                      <code>/services</code> directory.
                    </p>
                    <h3 id="where-can-i-see-my-deployed-kstreams-apps">
                      <a
                        data-id="where-can-i-see-my-deployed-kstreams-apps"
                      >
                        <span>Where can I see my deployed kstreams apps?</span>
                      </a>
                    </h3>
                    <p>
                      All deployments including your websocket application can be found
                      under your GCP account Cloud Run. In case you need to access the UI
                      link at a later time it can be found under websocket application.
                    </p>
                    <h3 id="which-deploysh-and-destroysh-should-i-run">
                      <a

                        data-id="which-deploysh-and-destroysh-should-i-run"

                      >
                        <span>Which deploy.sh and destroy.sh should I run?</span>
                      </a>
                    </h3>
                    <p>
                      When deploying and destroying the project please run the root
                      directory script files.{" "}
                    </p>
                    <h3 id="is-there-a-shortcut-to-pass-environment-variables-once-instead-providing-them-every-time-i-deploy">
                      <a

                        data-id="is-there-a-shortcut-to-pass-environment-variables-once-instead-providing-them-every-time-i-deploy"

                      >
                        <span>
                          Is there a shortcut to pass environment variables once instead
                          providing them every time I deploy?
                        </span>
                      </a>
                    </h3>
                    <p>
                      Yes, after your first deploy you can find all of them under your .env
                      file. Be sure to export these variables before your next deploy.
                    </p>
                    <h3 id="i-am-hitting-quoterror-error-reading-kafka-topic-401-api-key-based-authentication-failed-api-key-based-authentication-failedquot-error-while-rotating-my-keys-how-can-i-fix-this">
                      <a
                        data-id="i-am-hitting-quoterror-error-reading-kafka-topic-401-api-key-based-authentication-failed-api-key-based-authentication-failedquot-error-while-rotating-my-keys-how-can-i-fix-this"

                      >
                        <span>
                          I'm hitting "Error: error reading Kafka Topic: 401 API-key based
                          authentication failed.: API-key based authentication failed."
                          error while rotating my keys. How can I fix this?
                        </span>
                      </a>
                    </h3>
                    <p>
                      Kindly check if this is a key propagation issue and if the enough time
                      has passed after creation. Check if all permissions, ACLs, etc are
                      correctly set. If everything looks in place then most probably the
                      revoked API values were cached in the credentials section of the
                      terraform resource confluent_kafka_topic. A{" "}
                      <code>terraform apply -refresh=false</code> under{" "}
                      <code>/infrastructure</code> directory should correct the issue.
                    </p>
                    <h2 id="next-steps-improving-the-results">
                      <a
                        data-id="next-steps-improving-the-results"

                      >
                        <span>Next Steps - Improving the Results</span>
                      </a>
                    </h2>
                  </article>
                </section>
              </main>
              {/* Docsify v4 */}
              <div className="progress" style={{ opacity: 0, width: "0%" }} />
            </>


          );
          };

export default HelpForm;