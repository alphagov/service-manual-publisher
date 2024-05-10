class ServiceToolkitPresenter
  TOOLKIT_CONTENT_ID = "7397b402-57cd-4208-9d6b-1f59245f3c75".freeze

  def content_id
    TOOLKIT_CONTENT_ID
  end

  def content_payload
    {
      base_path: "/service-toolkit",
      title: "Service Toolkit",
      description: "All you need to design, build and run services that meet government standards.",
      details: {
        collections:,
      },
      routes: [
        { type: "exact", path: "/service-toolkit" },
      ],
      document_type: "service_manual_service_toolkit",
      schema_name: "service_manual_service_toolkit",
      publishing_app: "service-manual-publisher",
      rendering_app: "government-frontend",
      locale: "en",
    }
  end

  def links_payload
    { links: {} }
  end

  def collections
    [
      {
        "title": "Technology standards and guidance",
        "description": "Designing, building and buying technology for government",
        "links": [
          {
            "title": "Technology Code of Practice",
            "url": "https://www.gov.uk/guidance/the-technology-code-of-practice",
            "description": "The standard you must meet to get approval to spend money on technology or a service",
          },
          {
            "title": "Technology guidance",
            "url": "https://www.gov.uk/guidance/government-technology-standards-and-guidance",
            "description": "Guidance on accessibility, hosting, networking, open source, procurement, security and more",
          },
        ],
      },

      {
        "title": "Service standards and guidance",
        "description": "Creating and running government services",
        "links": [
          {
            "title": "Design principles",
            "url": "https://www.gov.uk/guidance/government-design-principles",
            "description": "Principles to help guide teams creating government services",
          },
          {
            "title": "Service Standard",
            "url": "https://www.gov.uk/service-manual/service-standard",
            "description": "The standard that government services need to meet",
          },
          {
            "title": "Service Manual",
            "url": "https://www.gov.uk/service-manual",
            "description": "Guidance on accessibility and assisted digital, agile delivery, design, measuring success, user research and more",
          },
          {
            "title": "GOV.UK Design System",
            "url": "https://design-system.service.gov.uk/",
            "description": "Styles, patterns and components for building GOV.UK services",
          },
          {
            "title": "GOV.UK Prototype Kit",
            "url": "https://govuk-prototype-kit.herokuapp.com/docs",
            "description": "Create rapid prototypes of GOV.UK services",
          },
        ],
      },

      {
        "title": "Platforms and tools",
        "description": "Technologies to help you build and run government services",
        "links": [
          {
            "title": "GOV.UK Notify",
            "url": "https://www.notifications.service.gov.uk/",
            "description": "Send your users emails, text messages and letters - cheaply and easily",
          },
          {
            "title": "GOV.UK Pay",
            "url": "https://www.payments.service.gov.uk/",
            "description": "Collect and process payments - providing a simple experience for users and easy integration for service teams",
          },
          {
            "title": "GOV.UK One Login (beta)",
            "url": "https://www.sign-in.service.gov.uk/",
            "description": "Lets your users sign in and prove their identity so they can access your service quickly and easily",
          },
          {
            "title": "GOV.UK Forms (beta)",
            "url": "https://www.forms.service.gov.uk/",
            "description": "A new platform that makes it easy to create accessible online forms for GOV.UK",
          },
        ],
      },

      {
        "title": "Spend controls and assurance",
        "description": "Assurance for technology spending and digital services",
        "links": [
          {
            "title": "Spend controls",
            "url": "https://www.gov.uk/government/collections/cabinet-office-controls",
            "description": "When and how to get approval to spend money on digital and technology",
          },
          {
            "title": "Service Standard and assessments",
            "url": "https://www.gov.uk/service-manual/service-assessments/check-if-need-to-meet-service-standard",
            "description": "Check if you need to follow the Service Standard or get a service assessment",
          },
        ],
      },

      {
        "title": "Buying technology and getting help with delivery",
        "description": "Procurement frameworks and delivery support",
        "links": [
          {
            "title": "Digital Marketplace",
            "url": "https://www.digitalmarketplace.service.gov.uk/",
            "description": "Use the G-Cloud or DOS frameworks to procure technology and find people to help deliver digital products and services",
          },
        ],
      },
    ]
  end
end
