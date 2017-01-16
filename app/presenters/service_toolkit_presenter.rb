class ServiceToolkitPresenter
  TOOLKIT_CONTENT_ID = "7397b402-57cd-4208-9d6b-1f59245f3c75".freeze

  def content_id
    TOOLKIT_CONTENT_ID
  end

  def content_payload
    {
      base_path: '/service-toolkit',
      title: 'Service Toolkit',
      description: 'All you need to design, build and run services that meet government standards.',
      details: {
        collections: collections
      },
      routes: [
        { type: 'exact', path: '/service-toolkit' }
      ],
      document_type: 'service_manual_service_toolkit',
      schema_name: 'service_manual_service_toolkit',
      publishing_app: 'service-manual-publisher',
      rendering_app: 'service-manual-frontend',
      locale: 'en'
    }
  end

  def collections
    [
      {
        "title": "Standards",
        "description": "Meet the standards for government services",
        "links": [
          {
            "title": "The Digital Service Standard",
            "url": "https://www.gov.uk/service-manual/service-standard",
            "description": "Learn about the 18 point standard that government services must meet"
          },
          {
            "title": "Service Manual",
            "url": "https://www.gov.uk/service-manual",
            "description": "How to build services to meet the Digital Service Standard, including agile delivery, technology, user research, design and training options"
          },
          {
            "title": "Technology Code of Practice",
            "url": "https://www.gov.uk/government/publications/technology-code-of-practice/technology-code-of-practice",
            "description": "Guidelines you must follow to get approval to spend money on a service"
          }
        ]
      },
      {
        "title": "Design and style",
        "description": "Resources for interface and content design",
        "links": [
          {
            "title": "Design Principles",
            "url": "https://www.gov.uk/design-principles",
            "description": "Principles you must follow as you design your service"
          },
          {
            "title": "Design patterns",
            "url": "https://www.gov.uk/service-manual/user-centred-design/resources/patterns",
            "description": "Reusable code and standards to solve common design problems"
          },
          {
            "title": "Reusable frontend code",
            "url": "https://www.gov.uk/service-manual/design#working-with-frontend",
            "description": "Use the GOV.UK template, frontend toolkit, elements, header and footer"
          },
          {
            "title": "GOV.UK prototype kit",
            "url": "https://govuk-prototype-kit.herokuapp.com/docs",
            "description": "Make HTML prototypes for user research and service design"
          },
          {
            "title": "Style guide",
            "url": "https://www.gov.uk/guidance/style-guide",
            "description": "Style, spelling and grammar conventions for government"
          }
        ]
      },
      {
        "title": "Components",
        "description": "Technologies designed to help you build and run government services",
        "links": [
          {
            "title": "GOV.UK Notify",
            "url": "https://www.notifications.service.gov.uk/",
            "description": "Keep your users updated with emails, text messages and letters, cheaply and easily"
          },
          {
            "title": "GOV.UK Pay",
            "url": "https://www.gov.uk/government/publications/govuk-pay/govuk-pay",
            "description": "Take and process payments - a simple experience for users and easy integration for you"
          },
          {
            "title": "GOV.UK Verify",
            "url": "http://alphagov.github.io/identity-assurance-documentation/",
            "description": "Let users prove their identity to you securely and conveniently"
          },
          {
            "title": "Platform as a Service (PaaS) for government",
            "url": "https://www.gov.uk/government/publications/platform-as-a-service/platform-as-a-service",
            "description": "Host your service on a government cloud platform without having to build and manage your own infrastructure"
          },
          {
            "title": "Registers",
            "url": "https://www.gov.uk/government/publications/registers/registers",
            "description": "Get authoritative datasets your service can rely on"
          }
        ]
      },
      {
        "title": "Monitoring",
        "description": "Get the data you need to improve your service",
        "links": [
          {
            "title": "Performance Platform",
            "url": "https://www.gov.uk/performance",
            "description": "Create a performance dashboard for your service"
          }
        ]
      },
      {
        "title": "Buying",
        "description": "Extra skills, people and technology to help build your service",
        "links": [
          {
            "title": "Digital Marketplace",
            "url": "https://www.gov.uk/digital-marketplace",
            "description": "Buy cloud technology and specialist services for digital projects"
          }
        ]
      }
    ]
  end
end
