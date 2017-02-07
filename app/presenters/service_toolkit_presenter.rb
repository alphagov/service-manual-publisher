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
        "description": "Standards for creating and running government services",
        "links": [
          {
            "title": "Digital Service Standard",
            "url": "https://www.gov.uk/service-manual/service-standard",
            "description": "The 18-point standard that government services must meet"
          },
          {
            "title": "Service Manual",
            "url": "https://www.gov.uk/service-manual",
            "description": "Guidance on how to research, design and build services that meet the Digital Service Standard"
          },
          {
            "title": "Technology Code of Practice",
            "url": "https://www.gov.uk/government/publications/technology-code-of-practice/technology-code-of-practice",
            "description": "The standard you must meet to get approval to spend money on technology or a service"
          }
        ]
      },
      {
        "title": "Design and style",
        "description": "Interaction and content design resources",
        "links": [
          {
            "title": "Design Principles",
            "url": "https://www.gov.uk/design-principles",
            "description": "10 principles to guide you as you design your service"
          },
          {
            "title": "Design patterns",
            "url": "https://www.gov.uk/service-manual/user-centred-design/resources/patterns",
            "description": "Evidence-based solutions to common design problems"
          },
          {
            "title": "Frontend code",
            "url": "https://www.gov.uk/service-manual/design#working-with-frontend",
            "description": "Resources for creating services that look consistent with GOV.UK"
          },
          {
            "title": "GOV.UK prototype kit",
            "url": "https://govuk-prototype-kit.herokuapp.com/docs",
            "description": "Code and templates for building realistic prototypes"
          },
          {
            "title": "Style guide",
            "url": "https://www.gov.uk/guidance/style-guide",
            "description": "Style, spelling and grammar conventions for digital content"
          }
        ]
      },
      {
        "title": "Components",
        "description": "Technologies designed to help you build and run government services",
        "links": [
          {
            "title": "GOV.UK Notify",
            "url": "https://www.notifications.service.gov.uk",
            "description": "Keep your users updated with emails, text messages and letters, cheaply and easily"
          },
          {
            "title": "GOV.UK Pay",
            "url": "https://www.payments.service.gov.uk",
            "description": "Take and process payments - a simple experience for users and easy integration for you"
          },
          {
            "title": "GOV.UK Verify",
            "url": "https://govuk-verify.cloudapps.digital",
            "description": "Let users prove their identity to you securely and conveniently"
          },
          {
            "title": "GOV.UK Platform as a Service",
            "url": "https://www.cloud.service.gov.uk",
            "description": "Host your service on a government cloud platform without having to build and manage your own infrastructure"
          },
          {
            "title": "Registers",
            "url": "https://registers.cloudapps.digital",
            "description": "Get authoritative datasets your service can rely on"
          }
        ]
      },
      {
        "title": "Monitoring",
        "description": "Data on service performance",
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
        "description": "Skills and technology for building digital services",
        "links": [
          {
            "title": "Digital Marketplace",
            "url": "https://www.gov.uk/digital-marketplace",
            "description": "Source cloud technology and specialist services for digital projects"
          }
        ]
      }
    ]
  end
end
